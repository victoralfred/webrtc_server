/*
 * Copyright 2014 Intel Corporation All Rights Reserved.
 *
 * The source code contained or described herein and all documents related to the
 * source code ("Material") are owned by Intel Corporation or its suppliers or
 * licensors. Title to the Material remains with Intel Corporation or its suppliers
 * and licensors. The Material contains trade secrets and proprietary and
 * confidential information of Intel or its suppliers and licensors. The Material
 * is protected by worldwide copyright and trade secret laws and treaty provisions.
 * No part of the Material may be used, copied, reproduced, modified, published,
 * uploaded, posted, transmitted, distributed, or disclosed in any way without
 * Intel's prior express written permission.
 *
 * No license under any patent, copyright, trade secret or other intellectual
 * property right is granted to or conferred upon you by disclosure or delivery of
 * the Materials, either expressly, by implication, inducement, estoppel or
 * otherwise. Any license under such intellectual property rights must be express
 * and approved by Intel in writing.
 */

#include "VideoCompositor.h"

#include "Config.h"
#include <webrtc/common_video/interface/i420_video_frame.h>
#include <webrtc/modules/video_processing/main/interface/video_processing.h>
#include <webrtc/system_wrappers/interface/clock.h>
#include <webrtc/system_wrappers/interface/critical_section_wrapper.h>
#include <webrtc/system_wrappers/interface/tick_util.h>

using namespace webrtc;

namespace mcu {

VPMPool::VPMPool(unsigned int size)
    : m_size(size)
{
    m_subVideSize.resize(size);
    m_vpms = new VideoProcessingModule*[size];
    for (unsigned int i = 0; i < m_size; i++) {
        VideoProcessingModule* vpm = VideoProcessingModule::Create(i);
        vpm->SetInputFrameResampleMode(webrtc::kFastRescaling);
        m_vpms[i] = vpm;
    }
}

VPMPool::~VPMPool()
{
    for (unsigned int i = 0; i < m_size; i++) {
        if (m_vpms[i])
            VideoProcessingModule::Destroy(m_vpms[i]);
    }
    delete[] m_vpms;
}

VideoProcessingModule* VPMPool::get(unsigned int slot)
{
    assert (slot < m_size);
    return m_vpms[slot];
}

void VPMPool::update(unsigned int slot, VideoSize& videoSize)
{
    m_subVideSize[slot] = videoSize;
    // FIXME: Get rid of the hard coded fps here.
    // Also it may need to be associated with the layout timer interval configured in VideoCompositor.
    if (m_vpms[slot])
        m_vpms[slot]->SetTargetResolution(videoSize.width, videoSize.height, 30);
}

DEFINE_LOGGER(SoftVideoCompositor, "mcu.media.SoftVideoCompositor");

SoftVideoCompositor::SoftVideoCompositor()
    : m_configLock(CriticalSectionWrapper::CreateCriticalSection())
    , m_configChanged(false)
{
    m_ntpDelta = Clock::GetRealTimeClock()->CurrentNtpInMilliseconds() - TickTime::MillisecondTimestamp();
    m_vpmPool.reset(new VPMPool(MAX_VIDEO_SLOT_NUMBER));

    // Default video layout definition
    m_currentLayout.rootSize = vga;    // Default to VGA
    m_currentLayout.rootColor = black; // Default to Black
    m_currentLayout.divFactor = 1;

    // Fetch the video size
    unsigned int videoWidth = DEFAULT_VIDEO_SIZE.width;
    unsigned int videoHeight = DEFAULT_VIDEO_SIZE.height;
    std::map<VideoResolutionType, VideoSize>::const_iterator it = VideoSizes.find(m_currentLayout.rootSize);
    if (it != VideoSizes.end()) {
        videoWidth = it->second.width;
        videoHeight = it->second.height;
    }

    // Initialize frame buffer and buffer manager for video composition
    m_composedFrame.reset(new webrtc::I420VideoFrame());
    m_composedFrame->CreateEmptyFrame(videoWidth, videoHeight, videoWidth, videoWidth / 2, videoWidth / 2);
    m_bufferManager.reset(new BufferManager(videoWidth, videoHeight));

    // Set the initialized video layout
    setLayout(m_currentLayout);

    m_jobTimer.reset(new JobTimer(30, this));
}

SoftVideoCompositor::~SoftVideoCompositor()
{
    m_consumers.clear();
}

void SoftVideoCompositor::setBitrate(int id, unsigned short bitrate)
{
}

void SoftVideoCompositor::requestKeyFrame(int id)
{
}

void SoftVideoCompositor::setLayout(struct VideoLayout& layout)
{
    webrtc::CriticalSectionScoped cs(m_configLock.get());
    ELOG_DEBUG("Configuring layout");
    m_newLayout = layout;
    m_configChanged = true;
    ELOG_DEBUG("configChanged is true");
}

bool SoftVideoCompositor::activateInput(int slot, FrameFormat format, VideoFrameProvider* provider)
{
    assert(format == FRAME_FORMAT_I420);

    m_bufferManager->setActive(slot, true);
    onSlotNumberChanged(m_bufferManager->activeSlots());
    return true;
}

void SoftVideoCompositor::deActivateInput(int slot)
{
    m_bufferManager->setActive(slot, false);
    onSlotNumberChanged(m_bufferManager->activeSlots());
}

void SoftVideoCompositor::pushInput(int slot, unsigned char* payload, int len)
{
    I420VideoFrame* frame = reinterpret_cast<I420VideoFrame*>(payload);
    I420VideoFrame* freeFrame = m_bufferManager->getFreeBuffer();
    if (freeFrame) {
        freeFrame->CopyFrame(*frame);
        I420VideoFrame* busyFrame = m_bufferManager->postFreeBuffer(freeFrame, slot);
        if (busyFrame)
            m_bufferManager->releaseBuffer(busyFrame);
    }
}

bool SoftVideoCompositor::activateOutput(int id, FrameFormat format, unsigned int framerate, unsigned short bitrate, VideoFrameConsumer* consumer)
{
    assert(format == FRAME_FORMAT_I420);

    boost::upgrade_lock<boost::shared_mutex> lock(m_consumerMutex);
    std::map<int, VideoFrameConsumer*>::iterator it = m_consumers.find(id);
    if (it != m_consumers.end())
        return false;

    boost::upgrade_to_unique_lock<boost::shared_mutex> uniqueLock(lock);
    m_consumers[id] = consumer;
    return true;
}

void SoftVideoCompositor::deActivateOutput(int id)
{
    boost::upgrade_lock<boost::shared_mutex> lock(m_consumerMutex);
    std::map<int, VideoFrameConsumer*>::iterator it = m_consumers.find(id);
    if (it != m_consumers.end()) {
        boost::upgrade_to_unique_lock<boost::shared_mutex> uniqueLock(lock);
        m_consumers.erase(it);
    }
}

void SoftVideoCompositor::onTimeout()
{
    generateFrame();
}

void SoftVideoCompositor::generateFrame()
{
    boost::shared_lock<boost::shared_mutex> lock(m_consumerMutex);
    if (!m_consumers.empty()) {
        I420VideoFrame* composedFrame = layout();
        composedFrame->set_render_time_ms(TickTime::MillisecondTimestamp() - m_ntpDelta);

        std::map<int, VideoFrameConsumer*>::iterator it = m_consumers.begin();
        for (; it != m_consumers.end(); ++it)
            it->second->onFrame(FRAME_FORMAT_I420, reinterpret_cast<unsigned char*>(composedFrame), 0, 0);
    }
}

void SoftVideoCompositor::onSlotNumberChanged(uint32_t newSlotNum)
{
    // Update the video layout according to the new input number
    if (Config::get()->updateVideoLayout(newSlotNum)) {
        ELOG_DEBUG("Video layout updated with new slot number changed to %d", newSlotNum);
    }
}

void SoftVideoCompositor::setBackgroundColor()
{
    if (m_composedFrame) {
        ELOG_DEBUG("setBackgroundColor");

        // Fetch video background color.
        YUVColor rootColor = DEFAULT_VIDEO_BG_COLOR;
        std::map<VideoBackgroundColor, YUVColor>::const_iterator it = VideoYuvColors.find(m_currentLayout.rootColor);
        if (it != VideoYuvColors.end())
            rootColor = it->second;

        // Set the background color
        memset(m_composedFrame->buffer(webrtc::kYPlane), rootColor.y, m_composedFrame->allocated_size(webrtc::kYPlane));
        memset(m_composedFrame->buffer(webrtc::kUPlane), rootColor.cb, m_composedFrame->allocated_size(webrtc::kUPlane));
        memset(m_composedFrame->buffer(webrtc::kVPlane), rootColor.cr, m_composedFrame->allocated_size(webrtc::kVPlane));
    }
}

bool SoftVideoCompositor::commitLayout()
{
    // Update the current video layout
    m_currentLayout = m_newLayout;

    // Fetch video size.
    VideoSize rootSize = DEFAULT_VIDEO_SIZE;
    std::map<VideoResolutionType, VideoSize>::const_iterator it = VideoSizes.find(m_currentLayout.rootSize);
    if (it != VideoSizes.end())
        rootSize = it->second;

    // Update the vpm pool size
    if (m_currentLayout.regions.empty()) { //fluid layout
        VideoSize videoSize;
        videoSize.width = rootSize.width / m_currentLayout.divFactor;
        videoSize.height = rootSize.height / m_currentLayout.divFactor;
        m_currentLayout.subWidth = videoSize.width;
        m_currentLayout.subHeight = videoSize.height;
        for (uint32_t i = 0; i < m_vpmPool->size(); i++)
            m_vpmPool->update(i, videoSize);

        ELOG_DEBUG("commit fluidlayout, rooSize is %d, current subHeight is %d, current subWidth is %d",
                m_currentLayout.rootSize,  m_currentLayout.subHeight, m_currentLayout.subWidth);
    } else { //custom layout
        for (uint32_t i = 0; i < m_currentLayout.regions.size(); i++) {
            Region region = m_currentLayout.regions[i];
            VideoSize videoSize;
            videoSize.width = (int)(rootSize.width * region.relativeSize);
            videoSize.height = (int)(rootSize.height * region.relativeSize);
            m_vpmPool->update(i, videoSize);
        }
        ELOG_DEBUG("commit customlayout");
    }

    m_configChanged = false;
    ELOG_DEBUG("configChanged sets to false after commitLayout!");
    return true;
}

webrtc::I420VideoFrame* SoftVideoCompositor::layout()
{
    if (m_configChanged) {
        webrtc::CriticalSectionScoped cs(m_configLock.get());
        commitLayout();
    }

    // Update the background color
    setBackgroundColor();

    // Run the video layout operation
    if (m_currentLayout.regions.empty())
        return fluidLayout();

    return customLayout();
}

webrtc::I420VideoFrame* SoftVideoCompositor::customLayout()
{
    // Fetch video size
    VideoSize rootSize = DEFAULT_VIDEO_SIZE;
    std::map<VideoResolutionType, VideoSize>::const_iterator it = VideoSizes.find(m_currentLayout.rootSize);
    if (it != VideoSizes.end())
        rootSize = it->second;

    uint32_t input = 0;
    webrtc::I420VideoFrame* target = m_composedFrame.get();
    for (uint32_t index = 0; index < MAX_VIDEO_SLOT_NUMBER; ++index) {
        if (!m_bufferManager->isActive(index) || input >= m_currentLayout.regions.size())
            continue;

        Region region = m_currentLayout.regions[input];
        int sub_width = (int)(rootSize.width * region.relativeSize);
        int sub_height = (int)(rootSize.height * region.relativeSize);
        unsigned int offset_width = (unsigned int)(rootSize.width * region.left);
        unsigned int offset_height = (unsigned int)(rootSize.height * region.top);
        webrtc::I420VideoFrame* sub_image = m_bufferManager->getBusyBuffer(index);
        if (!sub_image) {
            for (int i = 0; i < sub_height; i++) {
                memset(target->buffer(webrtc::kYPlane) + (i+offset_height) * target->stride(webrtc::kYPlane) + offset_width,
                        0,
                        sub_width);
            }

            for (int i = 0; i < sub_height/2; i++) {
                memset(target->buffer(webrtc::kUPlane) + (i+offset_height/2) * target->stride(webrtc::kUPlane) + offset_width/2,
                        128,
                        sub_width/2);
                memset(target->buffer(webrtc::kVPlane) + (i+offset_height/2) * target->stride(webrtc::kVPlane) + offset_width/2,
                        128,
                        sub_width/2);
            }
        } else {
            I420VideoFrame* processedFrame = nullptr;
            int ret = m_vpmPool->get(input)->PreprocessFrame(*sub_image, &processedFrame);
            if (ret == VPM_OK && !processedFrame) {
                // do nothing
            } else if (ret == VPM_OK && processedFrame) {
                for (int i = 0; i < sub_height; i++) {
                    memcpy(target->buffer(webrtc::kYPlane) + (i+offset_height) * target->stride(webrtc::kYPlane) + offset_width,
                            processedFrame->buffer(webrtc::kYPlane) + i * processedFrame->stride(webrtc::kYPlane),
                            sub_width);
                }

                for (int i = 0; i < sub_height/2; i++) {
                    memcpy(target->buffer(webrtc::kUPlane) + (i+offset_height/2) * target->stride(webrtc::kUPlane) + offset_width/2,
                            processedFrame->buffer(webrtc::kUPlane) + i * processedFrame->stride(webrtc::kUPlane),
                            sub_width/2);
                    memcpy(target->buffer(webrtc::kVPlane) + (i+offset_height/2) * target->stride(webrtc::kVPlane) + offset_width/2,
                            processedFrame->buffer(webrtc::kVPlane) + i * processedFrame->stride(webrtc::kVPlane),
                            sub_width/2);
                }
            }
            // if return busy frame failed, which means a new busy frame has been posted
            // simply release the busy frame
            if (m_bufferManager->returnBusyBuffer(sub_image, index))
                m_bufferManager->releaseBuffer(sub_image);
        }
        ++input;
    }

    return m_composedFrame.get();
}

webrtc::I420VideoFrame* SoftVideoCompositor::fluidLayout()
{
    webrtc::I420VideoFrame* target = m_composedFrame.get();

    int input = 0;
    for (uint32_t index = 0; index < MAX_VIDEO_SLOT_NUMBER; ++index) {
        if (!m_bufferManager->isActive(index))
            continue;

        unsigned int offset_width = (input%m_currentLayout.divFactor) * m_currentLayout.subWidth;
        unsigned int offset_height = (input/m_currentLayout.divFactor) * m_currentLayout.subHeight;
        webrtc::I420VideoFrame* sub_image = m_bufferManager->getBusyBuffer(index);
        if (!sub_image) {
            for (uint32_t i = 0; i < m_currentLayout.subHeight; i++) {
                memset(target->buffer(webrtc::kYPlane) + (i+offset_height) * target->stride(webrtc::kYPlane) + offset_width,
                    0,
                    m_currentLayout.subWidth);
            }

            for (uint32_t i = 0; i < m_currentLayout.subHeight/2; i++) {
                memset(target->buffer(webrtc::kUPlane) + (i+offset_height/2) * target->stride(webrtc::kUPlane) + offset_width/2,
                    128,
                    m_currentLayout.subWidth/2);
                memset(target->buffer(webrtc::kVPlane) + (i+offset_height/2) * target->stride(webrtc::kVPlane) + offset_width/2,
                    128,
                    m_currentLayout.subWidth/2);
            }
        } else {
            I420VideoFrame* processedFrame = nullptr;
            int ret = m_vpmPool->get(input)->PreprocessFrame(*sub_image, &processedFrame);
            if (ret == VPM_OK && !processedFrame) {
                // do nothing
            } else if (ret == VPM_OK && processedFrame) {
                for (uint32_t i = 0; i < m_currentLayout.subHeight; i++) {
                    memcpy(target->buffer(webrtc::kYPlane) + (i+offset_height)* target->stride(webrtc::kYPlane) + offset_width,
                        processedFrame->buffer(webrtc::kYPlane) + i * processedFrame->stride(webrtc::kYPlane),
                        m_currentLayout.subWidth);
                }

                for (uint32_t i = 0; i < m_currentLayout.subHeight/2; i++) {
                    memcpy(target->buffer(webrtc::kUPlane) + (i+offset_height/2) * target->stride(webrtc::kUPlane) + offset_width/2,
                        processedFrame->buffer(webrtc::kUPlane) + i * processedFrame->stride(webrtc::kUPlane),
                        m_currentLayout.subWidth/2);
                    memcpy(target->buffer(webrtc::kVPlane) + (i+offset_height/2) * target->stride(webrtc::kVPlane) + offset_width/2,
                        processedFrame->buffer(webrtc::kVPlane) + i * processedFrame->stride(webrtc::kVPlane),
                        m_currentLayout.subWidth/2);
                }
            }
            // if return busy frame failed, which means a new busy frame has been posted
            // simply release the busy frame
            if (m_bufferManager->returnBusyBuffer(sub_image, index))
                m_bufferManager->releaseBuffer(sub_image);
        }
        ++input;
    }
    return m_composedFrame.get();
};

}

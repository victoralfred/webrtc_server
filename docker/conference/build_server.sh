// -*- C++ -*-
//===-------------------------- utility -----------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef _LIBCPP_UTILITY
#define _LIBCPP_UTILITY

/*
    utility synopsis

#include <initializer_list>

namespace std
{

template <class T>
    void
    swap(T& a, T& b);

namespace rel_ops
{
    template<class T> bool operator!=(const T&, const T&);
    template<class T> bool operator> (const T&, const T&);
    template<class T> bool operator<=(const T&, const T&);
    template<class T> bool operator>=(const T&, const T&);
}

template<class T>
void
swap(T& a, T& b) noexcept(is_nothrow_move_constructible<T>::value &&
                          is_nothrow_move_assignable<T>::value);

template <class T, size_t N>
void
swap(T (&a)[N], T (&b)[N]) noexcept(noexcept(swap(*a, *b)));

template <class T> T&& forward(typename remove_reference<T>::type& t) noexcept;  // constexpr in C++14
template <class T> T&& forward(typename remove_reference<T>::type&& t) noexcept; // constexpr in C++14

template <class T> typename remove_reference<T>::type&& move(T&&) noexcept;      // constexpr in C++14

template <class T>
    typename conditional
    <
        !is_nothrow_move_constructible<T>::value && is_copy_constructible<T>::value,
        const T&,
        T&&
    >::type
    move_if_noexcept(T& x) noexcept; // constexpr in C++14

template <class T> constexpr add_const_t<T>& as_const(T& t) noexcept;      // C++17
template <class T>                      void as_const(const T&&) = delete; // C++17

template <class T> typename add_rvalue_reference<T>::type declval() noexcept;

template <class T1, class T2>
struct pair
{
    typedef T1 first_type;
    typedef T2 second_type;

    T1 first;
    T2 second;

    pair(const pair&) = default;
    pair(pair&&) = default;
    explicit(see-below) constexpr pair();
    explicit(see-below) pair(const T1& x, const T2& y);                          // constexpr in C++14
    template <class U, class V> explicit(see-below) pair(U&& x, V&& y);          // constexpr in C++14
    template <class U, class V> explicit(see-below) pair(const pair<U, V>& p);   // constexpr in C++14
    template <class U, class V> explicit(see-below) pair(pair<U, V>&& p);        // constexpr in C++14
    template <class... Args1, class... Args2>
        pair(piecewise_construct_t, tuple<Args1...> first_args,
             tuple<Args2...> second_args);

    template <class U, class V> pair& operator=(const pair<U, V>& p);
    pair& operator=(pair&& p) noexcept(is_nothrow_move_assignable<T1>::value &&
                                       is_nothrow_move_assignable<T2>::value);
    template <class U, class V> pair& operator=(pair<U, V>&& p);

    void swap(pair& p) noexcept(is_nothrow_swappable_v<T1> &&
                                is_nothrow_swappable_v<T2>);
};

template <class T1, class T2> bool operator==(const pair<T1,T2>&, const pair<T1,T2>&); // constexpr in C++14
template <class T1, class T2> bool operator!=(const pair<T1,T2>&, const pair<T1,T2>&); // constexpr in C++14
template <class T1, class T2> bool operator< (const pair<T1,T2>&, const pair<T1,T2>&); // constexpr in C++14
template <class T1, class T2> bool operator> (const pair<T1,T2>&, const pair<T1,T2>&); // constexpr in C++14
template <class T1, class T2> bool operator>=(const pair<T1,T2>&, const pair<T1,T2>&); // constexpr in C++14
template <class T1, class T2> bool operator<=(const pair<T1,T2>&, const pair<T1,T2>&); // constexpr in C++14

template <class T1, class T2> pair<V1, V2> make_pair(T1&&, T2&&);   // constexpr in C++14
template <class T1, class T2>
void
swap(pair<T1, T2>& x, pair<T1, T2>& y) noexcept(noexcept(x.swap(y)));

struct piecewise_construct_t { explicit piecewise_construct_t() = default; };
inline constexpr piecewise_construct_t piecewise_construct = piecewise_construct_t();

template <class T> struct tuple_size;
template <size_t I, class T> struct tuple_element;

template <class T1, class T2> struct tuple_size<pair<T1, T2> >;
template <class T1, class T2> struct tuple_element<0, pair<T1, T2> >;
template <class T1, class T2> struct tuple_element<1, pair<T1, T2> >;

template<size_t I, class T1, class T2>
    typename tuple_element<I, pair<T1, T2> >::type&
    get(pair<T1, T2>&) noexcept; // constexpr in C++14

template<size_t I, class T1, class T2>
    const typename tuple_element<I, pair<T1, T2> >::type&
    get(const pair<T1, T2>&) noexcept; // constexpr in C++14

template<size_t I, class T1, class T2>
    typename tuple_element<I, pair<T1, T2> >::type&&
    get(pair<T1, T2>&&) noexcept; // constexpr in C++14

template<size_t I, class T1, class T2>
    const typename tuple_element<I, pair<T1, T2> >::type&&
    get(const pair<T1, T2>&&) noexcept; // constexpr in C++14

template<class T1, class T2>
    constexpr T1& get(pair<T1, T2>&) noexcept; // C++14

template<class T1, class T2>
    constexpr const T1& get(const pair<T1, T2>&) noexcept; // C++14

template<class T1, class T2>
    constexpr T1&& get(pair<T1, T2>&&) noexcept; // C++14

template<class T1, class T2>
    constexpr const T1&& get(const pair<T1, T2>&&) noexcept; // C++14

template<class T1, class T2>
    constexpr T1& get(pair<T2, T1>&) noexcept; // C++14

template<class T1, class T2>
    constexpr const T1& get(const pair<T2, T1>&) noexcept; // C++14

template<class T1, class T2>
    constexpr T1&& get(pair<T2, T1>&&) noexcept; // C++14

template<class T1, class T2>
    constexpr const T1&& get(const pair<T2, T1>&&) noexcept; // C++14

// C++14

template<class T, T... I>
struct integer_sequence
{
    typedef T value_type;

    static constexpr size_t size() noexcept;
};

template<size_t... I>
  using index_sequence = integer_sequence<size_t, I...>;

template<class T, T N>
  using make_integer_sequence = integer_sequence<T, 0, 1, ..., N-1>;
template<size_t N>
  using make_index_sequence = make_integer_sequence<size_t, N>;

template<class... T>
  using index_sequence_for = make_index_sequence<sizeof...(T)>;

template<class T, class U=T>
    T exchange(T& obj, U&& new_value);

// 20.2.7, in-place construction // C++17
struct in_place_t {
  explicit in_place_t() = default;
};
inline constexpr in_place_t in_place{};
template <class T>
  struct in_place_type_t {
    explicit in_place_type_t() = default;
  };
template <class T>
  inline constexpr in_place_type_t<T> in_place_type{};
template <size_t I>
  struct in_place_index_t {
    explicit in_place_index_t() = default;
  };
template <size_t I>
  inline constexpr in_place_index_t<I> in_place_index{};

}  // std

*/

#include <__config>
#include <__tuple>
#include <type_traits>
#include <initializer_list>
#include <cstddef>
#include <cstring>
#include <cstdint>
#include <version>
#include <__debug>

#if !defined(_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER)
#pragma GCC system_header
#endif

_LIBCPP_BEGIN_NAMESPACE_STD

namespace rel_ops
{

template<class _Tp>
inline _LIBCPP_INLINE_VISIBILITY
bool
operator!=(const _Tp& __x, const _Tp& __y)
{
    return !(__x == __y);
}

template<class _Tp>
inline _LIBCPP_INLINE_VISIBILITY
bool
operator> (const _Tp& __x, const _Tp& __y)
{
    return __y < __x;
}

template<class _Tp>
inline _LIBCPP_INLINE_VISIBILITY
bool
operator<=(const _Tp& __x, const _Tp& __y)
{
    return !(__y < __x);
}

template<class _Tp>
inline _LIBCPP_INLINE_VISIBILITY
bool
operator>=(const _Tp& __x, const _Tp& __y)
{
    return !(__x < __y);
}

}  // rel_ops

// swap_ranges is defined in <type_traits>`

// swap is defined in <type_traits>

// move_if_noexcept

template <class _Tp>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
#ifndef _LIBCPP_CXX03_LANG
typename conditional
<
    !is_nothrow_move_constructible<_Tp>::value && is_copy_constructible<_Tp>::value,
    const _Tp&,
    _Tp&&
>::type
#else  // _LIBCPP_CXX03_LANG
const _Tp&
#endif
move_if_noexcept(_Tp& __x) _NOEXCEPT
{
    return _VSTD::move(__x);
}

#if _LIBCPP_STD_VER > 14
template <class _Tp> constexpr add_const_t<_Tp>& as_const(_Tp& __t) noexcept { return __t; }
template <class _Tp>                        void as_const(const _Tp&&) = delete;
#endif

struct _LIBCPP_TEMPLATE_VIS piecewise_construct_t { explicit piecewise_construct_t() = default; };
#if defined(_LIBCPP_CXX03_LANG) || defined(_LIBCPP_BUILDING_LIBRARY)
extern _LIBCPP_EXPORTED_FROM_ABI const piecewise_construct_t piecewise_construct;// = piecewise_construct_t();
#else
/* _LIBCPP_INLINE_VAR */ constexpr piecewise_construct_t piecewise_construct = piecewise_construct_t();
#endif

#if defined(_LIBCPP_DEPRECATED_ABI_DISABLE_PAIR_TRIVIAL_COPY_CTOR)
template <class, class>
struct __non_trivially_copyable_base {
  _LIBCPP_CONSTEXPR _LIBCPP_INLINE_VISIBILITY
  __non_trivially_copyable_base() _NOEXCEPT {}
  _LIBCPP_CONSTEXPR_AFTER_CXX11 _LIBCPP_INLINE_VISIBILITY
  __non_trivially_copyable_base(__non_trivially_copyable_base const&) _NOEXCEPT {}
};
#endif

template <class _T1, class _T2>
struct _LIBCPP_TEMPLATE_VIS pair
#if defined(_LIBCPP_DEPRECATED_ABI_DISABLE_PAIR_TRIVIAL_COPY_CTOR)
: private __non_trivially_copyable_base<_T1, _T2>
#endif
{
    typedef _T1 first_type;
    typedef _T2 second_type;

    _T1 first;
    _T2 second;

#if !defined(_LIBCPP_CXX03_LANG)
    pair(pair const&) = default;
    pair(pair&&) = default;
#else
  // Use the implicitly declared copy constructor in C++03
#endif

#ifdef _LIBCPP_CXX03_LANG
    _LIBCPP_INLINE_VISIBILITY
    pair() : first(), second() {}

    _LIBCPP_INLINE_VISIBILITY
    pair(_T1 const& __t1, _T2 const& __t2) : first(__t1), second(__t2) {}

    template <class _U1, class _U2>
    _LIBCPP_INLINE_VISIBILITY
    pair(const pair<_U1, _U2>& __p) : first(__p.first), second(__p.second) {}

    _LIBCPP_INLINE_VISIBILITY
    pair& operator=(pair const& __p) {
        first = __p.first;
        second = __p.second;
        return *this;
    }
#else
    template <bool _Val>
    using _EnableB _LIBCPP_NODEBUG_TYPE = typename enable_if<_Val, bool>::type;

    struct _CheckArgs {
      template <int&...>
      static constexpr bool __enable_explicit_default() {
          return is_default_constructible<_T1>::value
              && is_default_constructible<_T2>::value
              && !__enable_implicit_default<>();
      }

      template <int&...>
      static constexpr bool __enable_implicit_default() {
          return __is_implicitly_default_constructible<_T1>::value
              && __is_implicitly_default_constructible<_T2>::value;
      }

      template <class _U1, class _U2>
      static constexpr bool __enable_explicit() {
          return is_constructible<first_type, _U1>::value
              && is_constructible<second_type, _U2>::value
              && (!is_convertible<_U1, first_type>::value
                  || !is_convertible<_U2, second_type>::value);
      }

      template <class _U1, class _U2>
      static constexpr bool __enable_implicit() {
          return is_constructible<first_type, _U1>::value
              && is_constructible<second_type, _U2>::value
              && is_convertible<_U1, first_type>::value
              && is_convertible<_U2, second_type>::value;
      }
    };

    template <bool _MaybeEnable>
    using _CheckArgsDep _LIBCPP_NODEBUG_TYPE = typename conditional<
      _MaybeEnable, _CheckArgs, __check_tuple_constructor_fail>::type;

    struct _CheckTupleLikeConstructor {
        template <class _Tuple>
        static constexpr bool __enable_implicit() {
            return __tuple_convertible<_Tuple, pair>::value;
        }

        template <class _Tuple>
        static constexpr bool __enable_explicit() {
            return __tuple_constructible<_Tuple, pair>::value
               && !__tuple_convertible<_Tuple, pair>::value;
        }

        template <class _Tuple>
        static constexpr bool __enable_assign() {
            return __tuple_assignable<_Tuple, pair>::value;
        }
    };

    template <class _Tuple>
    using _CheckTLC _LIBCPP_NODEBUG_TYPE = typename conditional<
        __tuple_like_with_size<_Tuple, 2>::value
            && !is_same<typename decay<_Tuple>::type, pair>::value,
        _CheckTupleLikeConstructor,
        __check_tuple_constructor_fail
    >::type;

    template<bool _Dummy = true, _EnableB<
            _CheckArgsDep<_Dummy>::__enable_explicit_default()
    > = false>
    explicit _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR
    pair() _NOEXCEPT_(is_nothrow_default_constructible<first_type>::value &&
                      is_nothrow_default_constructible<second_type>::value)
        : first(), second() {}

    template<bool _Dummy = true, _EnableB<
            _CheckArgsDep<_Dummy>::__enable_implicit_default()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR
    pair() _NOEXCEPT_(is_nothrow_default_constructible<first_type>::value &&
                      is_nothrow_default_constructible<second_type>::value)
        : first(), second() {}

    template <bool _Dummy = true, _EnableB<
             _CheckArgsDep<_Dummy>::template __enable_explicit<_T1 const&, _T2 const&>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    explicit pair(_T1 const& __t1, _T2 const& __t2)
        _NOEXCEPT_(is_nothrow_copy_constructible<first_type>::value &&
                   is_nothrow_copy_constructible<second_type>::value)
        : first(__t1), second(__t2) {}

    template<bool _Dummy = true, _EnableB<
            _CheckArgsDep<_Dummy>::template __enable_implicit<_T1 const&, _T2 const&>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    pair(_T1 const& __t1, _T2 const& __t2)
        _NOEXCEPT_(is_nothrow_copy_constructible<first_type>::value &&
                   is_nothrow_copy_constructible<second_type>::value)
        : first(__t1), second(__t2) {}

    template<class _U1, class _U2, _EnableB<
             _CheckArgs::template __enable_explicit<_U1, _U2>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    explicit pair(_U1&& __u1, _U2&& __u2)
        _NOEXCEPT_((is_nothrow_constructible<first_type, _U1>::value &&
                    is_nothrow_constructible<second_type, _U2>::value))
        : first(_VSTD::forward<_U1>(__u1)), second(_VSTD::forward<_U2>(__u2)) {}

    template<class _U1, class _U2, _EnableB<
            _CheckArgs::template __enable_implicit<_U1, _U2>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    pair(_U1&& __u1, _U2&& __u2)
        _NOEXCEPT_((is_nothrow_constructible<first_type, _U1>::value &&
                    is_nothrow_constructible<second_type, _U2>::value))
        : first(_VSTD::forward<_U1>(__u1)), second(_VSTD::forward<_U2>(__u2)) {}

    template<class _U1, class _U2, _EnableB<
            _CheckArgs::template __enable_explicit<_U1 const&, _U2 const&>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    explicit pair(pair<_U1, _U2> const& __p)
        _NOEXCEPT_((is_nothrow_constructible<first_type, _U1 const&>::value &&
                    is_nothrow_constructible<second_type, _U2 const&>::value))
        : first(__p.first), second(__p.second) {}

    template<class _U1, class _U2, _EnableB<
            _CheckArgs::template __enable_implicit<_U1 const&, _U2 const&>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    pair(pair<_U1, _U2> const& __p)
        _NOEXCEPT_((is_nothrow_constructible<first_type, _U1 const&>::value &&
                    is_nothrow_constructible<second_type, _U2 const&>::value))
        : first(__p.first), second(__p.second) {}

    template<class _U1, class _U2, _EnableB<
            _CheckArgs::template __enable_explicit<_U1, _U2>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    explicit pair(pair<_U1, _U2>&&__p)
        _NOEXCEPT_((is_nothrow_constructible<first_type, _U1&&>::value &&
                    is_nothrow_constructible<second_type, _U2&&>::value))
        : first(_VSTD::forward<_U1>(__p.first)), second(_VSTD::forward<_U2>(__p.second)) {}

    template<class _U1, class _U2, _EnableB<
            _CheckArgs::template __enable_implicit<_U1, _U2>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    pair(pair<_U1, _U2>&& __p)
        _NOEXCEPT_((is_nothrow_constructible<first_type, _U1&&>::value &&
                    is_nothrow_constructible<second_type, _U2&&>::value))
        : first(_VSTD::forward<_U1>(__p.first)), second(_VSTD::forward<_U2>(__p.second)) {}

    template<class _Tuple, _EnableB<
            _CheckTLC<_Tuple>::template __enable_explicit<_Tuple>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    explicit pair(_Tuple&& __p)
        : first(_VSTD::get<0>(_VSTD::forward<_Tuple>(__p))),
          second(_VSTD::get<1>(_VSTD::forward<_Tuple>(__p))) {}

    template<class _Tuple, _EnableB<
            _CheckTLC<_Tuple>::template __enable_implicit<_Tuple>()
    > = false>
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    pair(_Tuple&& __p)
        : first(_VSTD::get<0>(_VSTD::forward<_Tuple>(__p))),
          second(_VSTD::get<1>(_VSTD::forward<_Tuple>(__p))) {}

    template <class... _Args1, class... _Args2>
    _LIBCPP_INLINE_VISIBILITY
    pair(piecewise_construct_t __pc,
         tuple<_Args1...> __first_args, tuple<_Args2...> __second_args)
        _NOEXCEPT_((is_nothrow_constructible<first_type, _Args1...>::value &&
                    is_nothrow_constructible<second_type, _Args2...>::value))
        : pair(__pc, __first_args, __second_args,
                typename __make_tuple_indices<sizeof...(_Args1)>::type(),
                typename __make_tuple_indices<sizeof...(_Args2) >::type()) {}

    _LIBCPP_INLINE_VISIBILITY
    pair& operator=(typename conditional<
                        is_copy_assignable<first_type>::value &&
                        is_copy_assignable<second_type>::value,
                    pair, __nat>::type const& __p)
        _NOEXCEPT_(is_nothrow_copy_assignable<first_type>::value &&
                   is_nothrow_copy_assignable<second_type>::value)
    {
        first = __p.first;
        second = __p.second;
        return *this;
    }

    _LIBCPP_INLINE_VISIBILITY
    pair& operator=(typename conditional<
                        is_move_assignable<first_type>::value &&
                        is_move_assignable<second_type>::value,
                    pair, __nat>::type&& __p)
        _NOEXCEPT_(is_nothrow_move_assignable<first_type>::value &&
                   is_nothrow_move_assignable<second_type>::value)
    {
        first = _VSTD::forward<first_type>(__p.first);
        second = _VSTD::forward<second_type>(__p.second);
        return *this;
    }

    template <class _Tuple, _EnableB<
            _CheckTLC<_Tuple>::template __enable_assign<_Tuple>()
     > = false>
    _LIBCPP_INLINE_VISIBILITY
    pair& operator=(_Tuple&& __p) {
        first = _VSTD::get<0>(_VSTD::forward<_Tuple>(__p));
        second = _VSTD::get<1>(_VSTD::forward<_Tuple>(__p));
        return *this;
    }
#endif

    _LIBCPP_INLINE_VISIBILITY
    void
    swap(pair& __p) _NOEXCEPT_(__is_nothrow_swappable<first_type>::value &&
                               __is_nothrow_swappable<second_type>::value)
    {
        using _VSTD::swap;
        swap(first,  __p.first);
        swap(second, __p.second);
    }
private:

#ifndef _LIBCPP_CXX03_LANG
    template <class... _Args1, class... _Args2, size_t... _I1, size_t... _I2>
        _LIBCPP_INLINE_VISIBILITY
        pair(piecewise_construct_t,
             tuple<_Args1...>& __first_args, tuple<_Args2...>& __second_args,
             __tuple_indices<_I1...>, __tuple_indices<_I2...>);
#endif
};

#ifndef _LIBCPP_HAS_NO_DEDUCTION_GUIDES
template<class _T1, class _T2>
pair(_T1, _T2) -> pair<_T1, _T2>;
#endif // _LIBCPP_HAS_NO_DEDUCTION_GUIDES

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
bool
operator==(const pair<_T1,_T2>& __x, const pair<_T1,_T2>& __y)
{
    return __x.first == __y.first && __x.second == __y.second;
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
bool
operator!=(const pair<_T1,_T2>& __x, const pair<_T1,_T2>& __y)
{
    return !(__x == __y);
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
bool
operator< (const pair<_T1,_T2>& __x, const pair<_T1,_T2>& __y)
{
    return __x.first < __y.first || (!(__y.first < __x.first) && __x.second < __y.second);
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
bool
operator> (const pair<_T1,_T2>& __x, const pair<_T1,_T2>& __y)
{
    return __y < __x;
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
bool
operator>=(const pair<_T1,_T2>& __x, const pair<_T1,_T2>& __y)
{
    return !(__x < __y);
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
bool
operator<=(const pair<_T1,_T2>& __x, const pair<_T1,_T2>& __y)
{
    return !(__y < __x);
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
typename enable_if
<
    __is_swappable<_T1>::value &&
    __is_swappable<_T2>::value,
    void
>::type
swap(pair<_T1, _T2>& __x, pair<_T1, _T2>& __y)
                     _NOEXCEPT_((__is_nothrow_swappable<_T1>::value &&
                                 __is_nothrow_swappable<_T2>::value))
{
    __x.swap(__y);
}

template <class _Tp>
struct __unwrap_reference { typedef _LIBCPP_NODEBUG_TYPE _Tp type; };

template <class _Tp>
struct __unwrap_reference<reference_wrapper<_Tp> > { typedef _LIBCPP_NODEBUG_TYPE _Tp& type; };

#if _LIBCPP_STD_VER > 17
template <class _Tp>
struct unwrap_reference : __unwrap_reference<_Tp> { };

template <class _Tp>
struct unwrap_ref_decay : unwrap_reference<typename decay<_Tp>::type> { };
#endif // > C++17

template <class _Tp>
struct __unwrap_ref_decay
#if _LIBCPP_STD_VER > 17
    : unwrap_ref_decay<_Tp>
#else
    : __unwrap_reference<typename decay<_Tp>::type>
#endif
{ };

#ifndef _LIBCPP_CXX03_LANG

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
pair<typename __unwrap_ref_decay<_T1>::type, typename __unwrap_ref_decay<_T2>::type>
make_pair(_T1&& __t1, _T2&& __t2)
{
    return pair<typename __unwrap_ref_decay<_T1>::type, typename __unwrap_ref_decay<_T2>::type>
               (_VSTD::forward<_T1>(__t1), _VSTD::forward<_T2>(__t2));
}

#else  // _LIBCPP_CXX03_LANG

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
pair<_T1,_T2>
make_pair(_T1 __x, _T2 __y)
{
    return pair<_T1, _T2>(__x, __y);
}

#endif  // _LIBCPP_CXX03_LANG

template <class _T1, class _T2>
  struct _LIBCPP_TEMPLATE_VIS tuple_size<pair<_T1, _T2> >
    : public integral_constant<size_t, 2> {};

template <size_t _Ip, class _T1, class _T2>
struct _LIBCPP_TEMPLATE_VIS tuple_element<_Ip, pair<_T1, _T2> >
{
    static_assert(_Ip < 2, "Index out of bounds in std::tuple_element<std::pair<T1, T2>>");
};

template <class _T1, class _T2>
struct _LIBCPP_TEMPLATE_VIS tuple_element<0, pair<_T1, _T2> >
{
    typedef _LIBCPP_NODEBUG_TYPE _T1 type;
};

template <class _T1, class _T2>
struct _LIBCPP_TEMPLATE_VIS tuple_element<1, pair<_T1, _T2> >
{
    typedef _LIBCPP_NODEBUG_TYPE _T2 type;
};

template <size_t _Ip> struct __get_pair;

template <>
struct __get_pair<0>
{
    template <class _T1, class _T2>
    static
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    _T1&
    get(pair<_T1, _T2>& __p) _NOEXCEPT {return __p.first;}

    template <class _T1, class _T2>
    static
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    const _T1&
    get(const pair<_T1, _T2>& __p) _NOEXCEPT {return __p.first;}

#ifndef _LIBCPP_CXX03_LANG
    template <class _T1, class _T2>
    static
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    _T1&&
    get(pair<_T1, _T2>&& __p) _NOEXCEPT {return _VSTD::forward<_T1>(__p.first);}

    template <class _T1, class _T2>
    static
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    const _T1&&
    get(const pair<_T1, _T2>&& __p) _NOEXCEPT {return _VSTD::forward<const _T1>(__p.first);}
#endif  // _LIBCPP_CXX03_LANG
};

template <>
struct __get_pair<1>
{
    template <class _T1, class _T2>
    static
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    _T2&
    get(pair<_T1, _T2>& __p) _NOEXCEPT {return __p.second;}

    template <class _T1, class _T2>
    static
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    const _T2&
    get(const pair<_T1, _T2>& __p) _NOEXCEPT {return __p.second;}

#ifndef _LIBCPP_CXX03_LANG
    template <class _T1, class _T2>
    static
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    _T2&&
    get(pair<_T1, _T2>&& __p) _NOEXCEPT {return _VSTD::forward<_T2>(__p.second);}

    template <class _T1, class _T2>
    static
    _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
    const _T2&&
    get(const pair<_T1, _T2>&& __p) _NOEXCEPT {return _VSTD::forward<const _T2>(__p.second);}
#endif  // _LIBCPP_CXX03_LANG
};

template <size_t _Ip, class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
typename tuple_element<_Ip, pair<_T1, _T2> >::type&
get(pair<_T1, _T2>& __p) _NOEXCEPT
{
    return __get_pair<_Ip>::get(__p);
}

template <size_t _Ip, class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
const typename tuple_element<_Ip, pair<_T1, _T2> >::type&
get(const pair<_T1, _T2>& __p) _NOEXCEPT
{
    return __get_pair<_Ip>::get(__p);
}

#ifndef _LIBCPP_CXX03_LANG
template <size_t _Ip, class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
typename tuple_element<_Ip, pair<_T1, _T2> >::type&&
get(pair<_T1, _T2>&& __p) _NOEXCEPT
{
    return __get_pair<_Ip>::get(_VSTD::move(__p));
}

template <size_t _Ip, class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX11
const typename tuple_element<_Ip, pair<_T1, _T2> >::type&&
get(const pair<_T1, _T2>&& __p) _NOEXCEPT
{
    return __get_pair<_Ip>::get(_VSTD::move(__p));
}
#endif  // _LIBCPP_CXX03_LANG

#if _LIBCPP_STD_VER > 11
template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
constexpr _T1 & get(pair<_T1, _T2>& __p) _NOEXCEPT
{
    return __get_pair<0>::get(__p);
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
constexpr _T1 const & get(pair<_T1, _T2> const& __p) _NOEXCEPT
{
    return __get_pair<0>::get(__p);
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
constexpr _T1 && get(pair<_T1, _T2>&& __p) _NOEXCEPT
{
    return __get_pair<0>::get(_VSTD::move(__p));
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
constexpr _T1 const && get(pair<_T1, _T2> const&& __p) _NOEXCEPT
{
    return __get_pair<0>::get(_VSTD::move(__p));
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
constexpr _T1 & get(pair<_T2, _T1>& __p) _NOEXCEPT
{
    return __get_pair<1>::get(__p);
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
constexpr _T1 const & get(pair<_T2, _T1> const& __p) _NOEXCEPT
{
    return __get_pair<1>::get(__p);
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
constexpr _T1 && get(pair<_T2, _T1>&& __p) _NOEXCEPT
{
    return __get_pair<1>::get(_VSTD::move(__p));
}

template <class _T1, class _T2>
inline _LIBCPP_INLINE_VISIBILITY
constexpr _T1 const && get(pair<_T2, _T1> const&& __p) _NOEXCEPT
{
    return __get_pair<1>::get(_VSTD::move(__p));
}

#endif

#if _LIBCPP_STD_VER > 11

template<class _Tp, _Tp... _Ip>
struct _LIBCPP_TEMPLATE_VIS integer_sequence
{
    typedef _Tp value_type;
    static_assert( is_integral<_Tp>::value,
                  "std::integer_sequence can only be instantiated with an integral type" );
    static
    _LIBCPP_INLINE_VISIBILITY
    constexpr
    size_t
    size() noexcept { return sizeof...(_Ip); }
};

template<size_t... _Ip>
    using index_sequence = integer_sequence<size_t, _Ip...>;

#if __has_builtin(__make_integer_seq) && !defined(_LIBCPP_TESTING_FALLBACK_MAKE_INTEGER_SEQUENCE)

template <class _Tp, _Tp _Ep>
using __make_integer_sequence _LIBCPP_NODEBUG_TYPE = __make_integer_seq<integer_sequence, _Tp, _Ep>;

#else

template<typename _Tp, _Tp _Np> using __make_integer_sequence_unchecked _LIBCPP_NODEBUG_TYPE  =
  typename __detail::__make<_Np>::type::template __convert<integer_sequence, _Tp>;

template <class _Tp, _Tp _Ep>
struct __make_integer_sequence_checked
{
    static_assert(is_integral<_Tp>::value,
                  "std::make_integer_sequence can only be instantiated with an integral type" );
    static_assert(0 <= _Ep, "std::make_integer_sequence must have a non-negative sequence length");
    // Workaround GCC bug by preventing bad installations when 0 <= _Ep
    // https://gcc.gnu.org/bugzilla/show_bug.cgi?id=68929
    typedef _LIBCPP_NODEBUG_TYPE  __make_integer_sequence_unchecked<_Tp, 0 <= _Ep ? _Ep : 0> type;
};

template <class _Tp, _Tp _Ep>
using __make_integer_sequence _LIBCPP_NODEBUG_TYPE = typename __make_integer_sequence_checked<_Tp, _Ep>::type;

#endif

template<class _Tp, _Tp _Np>
    using make_integer_sequence = __make_integer_sequence<_Tp, _Np>;

template<size_t _Np>
    using make_index_sequence = make_integer_sequence<size_t, _Np>;

template<class... _Tp>
    using index_sequence_for = make_index_sequence<sizeof...(_Tp)>;

#endif  // _LIBCPP_STD_VER > 11

#if _LIBCPP_STD_VER > 11
template<class _T1, class _T2 = _T1>
inline _LIBCPP_INLINE_VISIBILITY _LIBCPP_CONSTEXPR_AFTER_CXX17
_T1 exchange(_T1& __obj, _T2 && __new_value)
{
    _T1 __old_value = _VSTD::move(__obj);
    __obj = _VSTD::forward<_T2>(__new_value);
    return __old_value;
}
#endif  // _LIBCPP_STD_VER > 11

#if _LIBCPP_STD_VER > 14

struct _LIBCPP_TYPE_VIS in_place_t {
    explicit in_place_t() = default;
};
_LIBCPP_INLINE_VAR constexpr in_place_t in_place{};

template <class _Tp>
struct _LIBCPP_TEMPLATE_VIS in_place_type_t {
    explicit in_place_type_t() = default;
};
template <class _Tp>
_LIBCPP_INLINE_VAR constexpr in_place_type_t<_Tp> in_place_type{};

template <size_t _Idx>
struct _LIBCPP_TYPE_VIS in_place_index_t {
    explicit in_place_index_t() = default;
};
template <size_t _Idx>
_LIBCPP_INLINE_VAR constexpr in_place_index_t<_Idx> in_place_index{};

template <class _Tp> struct __is_inplace_type_imp : false_type {};
template <class _Tp> struct __is_inplace_type_imp<in_place_type_t<_Tp>> : true_type {};

template <class _Tp>
using __is_inplace_type = __is_inplace_type_imp<__uncvref_t<_Tp>>;

template <class _Tp> struct __is_inplace_index_imp : false_type {};
template <size_t _Idx> struct __is_inplace_index_imp<in_place_index_t<_Idx>> : true_type {};

template <class _Tp>
using __is_inplace_index = __is_inplace_index_imp<__uncvref_t<_Tp>>;

#endif // _LIBCPP_STD_VER > 14

template <class _Arg, class _Result>
struct _LIBCPP_TEMPLATE_VIS unary_function
{
    typedef _Arg    argument_type;
    typedef _Result result_type;
};

template <class _Size>
inline _LIBCPP_INLINE_VISIBILITY
_Size
__loadword(const void* __p)
{
    _Size __r;
    std::memcpy(&__r, __p, sizeof(__r));
    return __r;
}

// We use murmur2 when size_t is 32 bits, and cityhash64 when size_t
// is 64 bits.  This is because cityhash64 uses 64bit x 64bit
// multiplication, which can be very slow on 32-bit systems.
template <class _Size, size_t = sizeof(_Size)*__CHAR_BIT__>
struct __murmur2_or_cityhash;

template <class _Size>
struct __murmur2_or_cityhash<_Size, 32>
{
    inline _Size operator()(const void* __key, _Size __len)
         _LIBCPP_DISABLE_UBSAN_UNSIGNED_INTEGER_CHECK;
};

// murmur2
template <class _Size>
_Size
__murmur2_or_cityhash<_Size, 32>::operator()(const void* __key, _Size __len)
{
    const _Size __m = 0x5bd1e995;
    const _Size __r = 24;
    _Size __h = __len;
    const unsigned char* __data = static_cast<const unsigned char*>(__key);
    for (; __len >= 4; __data += 4, __len -= 4)
    {
        _Size __k = __loadword<_Size>(__data);
        __k *= __m;
        __k ^= __k >> __r;
        __k *= __m;
        __h *= __m;
        __h ^= __k;
    }
    switch (__len)
    {
    case 3:
        __h ^= __data[2] << 16;
        _LIBCPP_FALLTHROUGH();
    case 2:
        __h ^= __data[1] << 8;
        _LIBCPP_FALLTHROUGH();
    case 1:
        __h ^= __data[0];
        __h *= __m;
    }
    __h ^= __h >> 13;
    __h *= __m;
    __h ^= __h >> 15;
    return __h;
}

template <class _Size>
struct __murmur2_or_cityhash<_Size, 64>
{
    inline _Size operator()(const void* __key, _Size __len)  _LIBCPP_DISABLE_UBSAN_UNSIGNED_INTEGER_CHECK;

 private:
  // Some primes between 2^63 and 2^64.
  static const _Size __k0 = 0xc3a5c85c97cb3127ULL;
  static const _Size __k1 = 0xb492b66fbe98f273ULL;
  static const _Size __k2 = 0x9ae16a3b2f90404fULL;
  static const _Size __k3 = 0xc949d7c7509e6557ULL;

  static _Size __rotate(_Size __val, int __shift) {
    return __shift == 0 ? __val : ((__val >> __shift) | (__val << (64 - __shift)));
  }

  static _Size __rotate_by_at_least_1(_Size __val, int __shift) {
    return (__val >> __shift) | (__val << (64 - __shift));
  }

  static _Size __shift_mix(_Size __val) {
    return __val ^ (__val >> 47);
  }

  static _Size __hash_len_16(_Size __u, _Size __v)
     _LIBCPP_DISABLE_UBSAN_UNSIGNED_INTEGER_CHECK
  {
    const _Size __mul = 0x9ddfea08eb382d69ULL;
    _Size __a = (__u ^ __v) * __mul;
    __a ^= (__a >> 47);
    _Size __b = (__v ^ __a) * __mul;
    __b ^= (__b >> 47);
    __b *= __mul;
    return __b;
  }

  static _Size __hash_len_0_to_16(const char* __s, _Size __len)
     _LIBCPP_DISABLE_UBSAN_UNSIGNED_INTEGER_CHECK
  {
    if (__len > 8) {
      const _Size __a = __loadword<_Size>(__s);
      const _Size __b = __loadword<_Size>(__s + __len - 8);
      return __hash_len_16(__a, __rotate_by_at_least_1(__b + __len, __len)) ^ __b;
    }
    if (__len >= 4) {
      const uint32_t __a = __loadword<uint32_t>(__s);
      const uint32_t __b = __loadword<uint32_t>(__s + __len - 4);
      return __hash_len_16(__len + (__a << 3), __b);
    }
    if (__len > 0) {
      const unsigned char __a = __s[0];
      const unsigned char __b = __s[__len >> 1];
      const unsigned char __c = __s[__len - 1];
      const uint32_t __y = static_cast<uint32_t>(__a) +
                           (static_cast<uint32_t>(__b) << 8);
      const uint32_t __z = __len + (static_cast<uint32_t>(__c) << 2);
      return __shift_mix(__y * __k2 ^ __z * __k3) * __k2;
    }
    return __k2;
  }

  static _Size __hash_len_17_to_32(const char *__s, _Size __len)
     _LIBCPP_DISABLE_UBSAN_UNSIGNED_INTEGER_CHECK
  {
    const _Size __a = __loadword<_Size>(__s) * __k1;
    const _Size __b = __loadword<_Size>(__s + 8);
    const _Size __c = __loadword<_Size>(__s + __len - 8) * __k2;
    const _Size __d = __loadword<_Size>(__s + __len - 16) * __k0;
    return __hash_len_16(__rotate(__a - __b, 43) + __rotate(__c, 30) + __d,
                         __a + __rotate(__b ^ __k3, 20) - __c + __len);
  }

  // Return a 16-byte hash for 48 bytes.  Quick and dirty.
  // Callers do best to use "random-looking" values for a and b.
  static pair<_Size, _Size> __weak_hash_len_32_with_seeds(
      _Size __w, _Size __x, _Size __y, _Size __z, _Size __a, _Size __b)
        _LIBCPP_DISABLE_UBSAN_UNSIGNED_INTEGER_CHECK
  {
    __a += __w;
    __b = __rotate(__b + __a + __z, 21);
    const _Size __c = __a;
    __a += __x;
    __a += __y;
    __b += __rotate(__a, 44);
    return pair<_Size, _Size>(__a + __z, __b + __c);
  }

  // Return a 16-byte hash for s[0] ... s[31], a, and b.  Quick and dirty.
  static pair<_Size, _Size> __weak_hash_len_32_with_seeds(
      const char* __s, _Size __a, _Size __b)
    _LIBCPP_DISABLE_UBSAN_UNSIGNED_INTEGER_CHECK
  {
    return __weak_hash_len_32_with_seeds(__loadword<_Size>(__s),
                                         __loadword<_Size>(__s + 8),
                                         __loadword<_Size>(__s + 16),
                                         __loadword<_Size>(__s + 24),
                                         __a,
                                         __b);
  }

  // Return an 8-byte hash for 33 to 64 bytes.
  static _Size __hash_len_33_to_64(const char *__s, size_t __len)
    _LIBCPP_DISABLE_UBSAN_UNSIGNED_INTEGER_CHECK
  {
    _Size __z = __loadword<_Size>(__s + 24);
    _Size __a = __loadword<_Size>(__s) +
                (__len + __loadword<_Size>(__s + __len - 16)) * __k0;
    _Size __b = __rotate(__a + __z, 52);
    _Size __c = __rotate(__a, 37);
    __a += __loadword<_Size>(__s + 8);
    __c += __rotate(__a, 7);
    __a += __loadword<_Size>(__s + 16);
    _Size __vf = __a + __z;
    _Size __vs = __b + __rotate(__a, 31) + __c;
    __a = __loadword<_Size>(__s + 16) + __loadword<_Size>(__s + __len - 32);
    __z += __loadword<_Size>(__s + __len - 8);
    __b = __rotate(__a + __z, 52);
    __c = __rotate(__a, 37);
    __a += __loadword<_Size>(__s + __len - 24);
    __c += __rotate(__a, 7);
    __a += __loadword<_Size>(__s + __len - 16);
    _Size __wf = __a + __z;
    _Size __ws = __b + __rotate(__a, 31) + __c;
    _Size __r = __shift_mix((__vf + __ws) * __k2 + (__wf + __vs) * __k0);
    return __shift_mix(__r * __k0 + __vs) * __k2;
  }
};

// cityhash64
template <class _Size>
_Size
__murmur2_or_cityhash<_Size, 64>::operator()(const void* __key, _Size __len)
{
  const char* __s = static_cast<const char*>(__key);
  if (__len <= 32) {
    if (__len <= 16) {
      return __hash_len_0_to_16(__s, __len);
    } else {
      return __hash_len_17_to_32(__s, __len);
    }
  } else if (__len <= 64) {
    return __hash_len_33_to_64(__s, __len);
  }

  // For strings over 64 bytes we hash the end first, and then as we
  // loop we keep 56 bytes of state: v, w, x, y, and z.
  _Size __x = __loadword<_Size>(__s + __len - 40);
  _Size __y = __loadword<_Size>(__s + __len - 16) +
              __loadword<_Size>(__s + __len - 56);
  _Size __z = __hash_len_16(__loadword<_Size>(__s + __len - 48) + __len,
                          __loadword<_Size>(__s + __len - 24));
  pair<_Size, _Size> __v = __weak_hash_len_32_with_seeds(__s + __len - 64, __len, __z);
  pair<_Size, _Size> __w = __weak_hash_len_32_with_seeds(__s + __len - 32, __y + __k1, __x);
  __x = __x * __k1 + __loadword<_Size>(__s);

  // Decrease len to the nearest multiple of 64, and operate on 64-byte chunks.
  __len = (__len - 1) & ~static_cast<_Size>(63);
  do {
    __x = __rotate(__x + __y + __v.first + __loadword<_Size>(__s + 8), 37) * __k1;
    __y = __rotate(__y + __v.second + __loadword<_Size>(__s + 48), 42) * __k1;
    __x ^= __w.second;
    __y += __v.first + __loadword<_Size>(__s + 40);
    __z = __rotate(__z + __w.first, 33) * __k1;
    __v = __weak_hash_len_32_with_seeds(__s, __v.second * __k1, __x + __w.first);
    __w = __weak_hash_len_32_with_seeds(__s + 32, __z + __w.second,
                                        __y + __loadword<_Size>(__s + 16));
    std::swap(__z, __x);
    __s += 64;
    __len -= 64;
  } while (__len != 0);
  return __hash_len_16(
      __hash_len_16(__v.first, __w.first) + __shift_mix(__y) * __k1 + __z,
      __hash_len_16(__v.second, __w.second) + __x);
}

template <class _Tp, size_t = sizeof(_Tp) / sizeof(size_t)>
struct __scalar_hash;

template <class _Tp>
struct __scalar_hash<_Tp, 0>
    : public unary_function<_Tp, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(_Tp __v) const _NOEXCEPT
    {
        union
        {
            _Tp    __t;
            size_t __a;
        } __u;
        __u.__a = 0;
        __u.__t = __v;
        return __u.__a;
    }
};

template <class _Tp>
struct __scalar_hash<_Tp, 1>
    : public unary_function<_Tp, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(_Tp __v) const _NOEXCEPT
    {
        union
        {
            _Tp    __t;
            size_t __a;
        } __u;
        __u.__t = __v;
        return __u.__a;
    }
};

template <class _Tp>
struct __scalar_hash<_Tp, 2>
    : public unary_function<_Tp, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(_Tp __v) const _NOEXCEPT
    {
        union
        {
            _Tp __t;
            struct
            {
                size_t __a;
                size_t __b;
            } __s;
        } __u;
        __u.__t = __v;
        return __murmur2_or_cityhash<size_t>()(&__u, sizeof(__u));
    }
};

template <class _Tp>
struct __scalar_hash<_Tp, 3>
    : public unary_function<_Tp, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(_Tp __v) const _NOEXCEPT
    {
        union
        {
            _Tp __t;
            struct
            {
                size_t __a;
                size_t __b;
                size_t __c;
            } __s;
        } __u;
        __u.__t = __v;
        return __murmur2_or_cityhash<size_t>()(&__u, sizeof(__u));
    }
};

template <class _Tp>
struct __scalar_hash<_Tp, 4>
    : public unary_function<_Tp, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(_Tp __v) const _NOEXCEPT
    {
        union
        {
            _Tp __t;
            struct
            {
                size_t __a;
                size_t __b;
                size_t __c;
                size_t __d;
            } __s;
        } __u;
        __u.__t = __v;
        return __murmur2_or_cityhash<size_t>()(&__u, sizeof(__u));
    }
};

struct _PairT {
  size_t first;
  size_t second;
};

_LIBCPP_INLINE_VISIBILITY
inline size_t __hash_combine(size_t __lhs, size_t __rhs) _NOEXCEPT {
    typedef __scalar_hash<_PairT> _HashT;
    const _PairT __p = {__lhs, __rhs};
    return _HashT()(__p);
}

template<class _Tp>
struct _LIBCPP_TEMPLATE_VIS hash<_Tp*>
    : public unary_function<_Tp*, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(_Tp* __v) const _NOEXCEPT
    {
        union
        {
            _Tp* __t;
            size_t __a;
        } __u;
        __u.__t = __v;
        return __murmur2_or_cityhash<size_t>()(&__u, sizeof(__u));
    }
};


template <>
struct _LIBCPP_TEMPLATE_VIS hash<bool>
    : public unary_function<bool, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(bool __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<char>
    : public unary_function<char, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(char __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<signed char>
    : public unary_function<signed char, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(signed char __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<unsigned char>
    : public unary_function<unsigned char, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(unsigned char __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

#ifndef _LIBCPP_HAS_NO_UNICODE_CHARS

template <>
struct _LIBCPP_TEMPLATE_VIS hash<char16_t>
    : public unary_function<char16_t, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(char16_t __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<char32_t>
    : public unary_function<char32_t, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(char32_t __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

#endif  // _LIBCPP_HAS_NO_UNICODE_CHARS

template <>
struct _LIBCPP_TEMPLATE_VIS hash<wchar_t>
    : public unary_function<wchar_t, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(wchar_t __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<short>
    : public unary_function<short, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(short __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<unsigned short>
    : public unary_function<unsigned short, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(unsigned short __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<int>
    : public unary_function<int, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(int __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<unsigned int>
    : public unary_function<unsigned int, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(unsigned int __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<long>
    : public unary_function<long, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(long __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<unsigned long>
    : public unary_function<unsigned long, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(unsigned long __v) const _NOEXCEPT {return static_cast<size_t>(__v);}
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<long long>
    : public __scalar_hash<long long>
{
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<unsigned long long>
    : public __scalar_hash<unsigned long long>
{
};

#ifndef _LIBCPP_HAS_NO_INT128

template <>
struct _LIBCPP_TEMPLATE_VIS hash<__int128_t>
    : public __scalar_hash<__int128_t>
{
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<__uint128_t>
    : public __scalar_hash<__uint128_t>
{
};

#endif

template <>
struct _LIBCPP_TEMPLATE_VIS hash<float>
    : public __scalar_hash<float>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(float __v) const _NOEXCEPT
    {
        // -0.0 and 0.0 should return same hash
       if (__v == 0.0f)
           return 0;
        return __scalar_hash<float>::operator()(__v);
    }
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<double>
    : public __scalar_hash<double>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(double __v) const _NOEXCEPT
    {
        // -0.0 and 0.0 should return same hash
       if (__v == 0.0)
           return 0;
        return __scalar_hash<double>::operator()(__v);
    }
};

template <>
struct _LIBCPP_TEMPLATE_VIS hash<long double>
    : public __scalar_hash<long double>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(long double __v) const _NOEXCEPT
    {
        // -0.0 and 0.0 should return same hash
        if (__v == 0.0L)
            return 0;
#if defined(__i386__)
        // Zero out padding bits
        union
        {
            long double __t;
            struct
            {
                size_t __a;
                size_t __b;
                size_t __c;
                size_t __d;
            } __s;
        } __u;
        __u.__s.__a = 0;
        __u.__s.__b = 0;
        __u.__s.__c = 0;
        __u.__s.__d = 0;
        __u.__t = __v;
        return __u.__s.__a ^ __u.__s.__b ^ __u.__s.__c ^ __u.__s.__d;
#elif defined(__x86_64__)
        // Zero out padding bits
        union
        {
            long double __t;
            struct
            {
                size_t __a;
                size_t __b;
            } __s;
        } __u;
        __u.__s.__a = 0;
        __u.__s.__b = 0;
        __u.__t = __v;
        return __u.__s.__a ^ __u.__s.__b;
#else
        return __scalar_hash<long double>::operator()(__v);
#endif
    }
};

#if _LIBCPP_STD_VER > 11

template <class _Tp, bool = is_enum<_Tp>::value>
struct _LIBCPP_TEMPLATE_VIS __enum_hash
    : public unary_function<_Tp, size_t>
{
    _LIBCPP_INLINE_VISIBILITY
    size_t operator()(_Tp __v) const _NOEXCEPT
    {
        typedef typename underlying_type<_Tp>::type type;
        return hash<type>{}(static_cast<type>(__v));
    }
};
template <class _Tp>
struct _LIBCPP_TEMPLATE_VIS __enum_hash<_Tp, false> {
    __enum_hash() = delete;
    __enum_hash(__enum_hash const&) = delete;
    __enum_hash& operator=(__enum_hash const&) = delete;
};

template <class _Tp>
struct _LIBCPP_TEMPLATE_VIS hash : public __enum_hash<_Tp>
{
};
#endif

#if _LIBCPP_STD_VER > 14

template <>
struct _LIBCPP_TEMPLATE_VIS hash<nullptr_t>
  : public unary_function<nullptr_t, size_t>
{
  _LIBCPP_INLINE_VISIBILITY
  size_t operator()(nullptr_t) const _NOEXCEPT {
    return 662607004ull;
  }
};
#endif

#ifndef _LIBCPP_CXX03_LANG
template <class _Key, class _Hash>
using __check_hash_requirements _LIBCPP_NODEBUG_TYPE  = integral_constant<bool,
    is_copy_constructible<_Hash>::value &&
    is_move_constructible<_Hash>::value &&
    __invokable_r<size_t, _Hash, _Key const&>::value
>;

template <class _Key, class _Hash = std::hash<_Key> >
using __has_enabled_hash _LIBCPP_NODEBUG_TYPE = integral_constant<bool,
    __check_hash_requirements<_Key, _Hash>::value &&
    is_default_constructible<_Hash>::value
>;

#if _LIBCPP_STD_VER > 14
template <class _Type, class>
using __enable_hash_helper_imp _LIBCPP_NODEBUG_TYPE  = _Type;

template <class _Type, class ..._Keys>
using __enable_hash_helper _LIBCPP_NODEBUG_TYPE  = __enable_hash_helper_imp<_Type,
  typename enable_if<__all<__has_enabled_hash<_Keys>::value...>::value>::type
>;
#else
template <class _Type, class ...>
using __enable_hash_helper _LIBCPP_NODEBUG_TYPE = _Type;
#endif

#endif // !_LIBCPP_CXX03_LANG

_LIBCPP_END_NAMESPACE_STD

#endif  // _LIBCPP_UTILITY
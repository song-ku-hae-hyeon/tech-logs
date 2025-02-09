---
title: Short Sentences
description: 간결한 문장에 대해 다룹니다.
sidebar_position: 3
tags:
  - technical-writing
---

간결한 문서는 더 강력하고 더 이해하기 쉽습니다. 이는 우리가 코드를 작성할 때와 유사합니다:

- 더 짧은 문서는 긴 문서보다 빨리 읽힌다.
- 더 짧은 문서는 긴 문서보다 유지보수하기 쉽다.
- 한 줄이 추가된다는 것은 추가적인 오류를 가져올 수 있다.

## Focus each sentence on a single idea

하나의 문장은 하나의 아이디어만을 갖도록 해야합니다.

:::danger[before]
“The late 1950s was a key era for programming languages because IBM introduced Fortran in 1957 and John McCarthy introduced Lisp the following year, which gave programmers both an iterative way of solving problems and a recursive way.”
:::

:::tip[after]
“The late 1950s was a key era for programming languages. IBM introduced Fortran in 1957. John McCarthy invented Lisp the following year. Consequently, by the late 1950s, programmers could solve problems iteratively or recursively.”
:::

## Convert some long sentences to lists

긴 문장에서 접속사들이 보인다면 목록으로 재구성하는 것을 고려해야 합니다.

:::danger[before]
“To alter the usual flow of a loop, you may use either a break statement (which hops you out of the current loop) or a continue statement (which skips past the remainder of the current iteration of the current loop)”
:::

:::tip[after]
To alter the usual flow of a loop, call one of the following statements:

- `break`, which hops you out of the current loop.
- `continue`, which skips past the remainder of the current iteration of the current loop.

:::

## Eliminate or reduce extraneous words

불필요한 단어는 독자의 이해를 방해하고 문장을 길게할 수도 있습니다.

:::danger[before]
“An input value greater than 100 causes the triggering of logging.”
:::

:::tip[after]
“An input value greater than 100 triggers logging.”
:::

## Reduce subordinate clauses

종속절(which, that)은 위에서 언급한 하나의 문장이 하나의 아이디어를 갖자는 원칙에 대부분 위반됩니다. 따라서 되도록 피하는 것이 좋습니다.

미국에서는 which는 필수적이지 않은, 추가 정보 제공에 쓰입니다. that은 문장에 필수적인 경우 쓰입니다. 이를 구분하기위해 which 앞에는 콤마를 사용하고 that 앞에는 사용하지 않도록 합니다.

## Wrap Up

짧은 문장은 독자가 더 쉽게 이해할 수 있도록 도와줍니다. 간결한 문장은 유지보수도 용이합니다.

### Summary

짧은 문장은 독자의 이해를 돕고, 문서의 가독성을 높입니다. 하나의 문장은 하나의 아이디어만을 포함해야 합니다. 긴 문장은 목록으로 재구성하는 것이 좋습니다. 불필요한 단어와 종속절을 줄여 문장을 간결하게 만드세요.

### Reference

- [Short Sentences | Technical Writing | Google for Developers](https://developers.google.com/tech-writing/one/short-sentences)

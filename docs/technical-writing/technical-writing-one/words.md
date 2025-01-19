---
title: Words
description: 기술 문서에서 적절한 단어와 약어를 사용하는 방식을 다룹니다.
sidebar_position: 1
tags:
  - technical-writing
---

## Define new or unfamiliar terms

글을 작성하거나 편집할 때 익숙하지 않거나 새로운 용어를 정의하는 법을 배우도록 합니다. 아래 두 가지 전략을 따라보세요:

- 기존 용어: 이미 존재하는 용어라면 신뢰할 수 있는 기존 설명으로 링크합니다.
- 신규 용어: 이번 문서에서 새롭게 소개된다면 명확히 정의해야 합니다. 이번 문서에 많은 용어가 소개된다면 용어들을 모아서 별도로 용어집을 제작하는 것도 좋습니다.

## Use terms consistently

한 번 정한 용어는 문서 전체에서 동일하게 사용되어야 합니다. 만약 긴 이름을 사용할 때 약어를 문서에서 사용한다면 아래와 같이 사용해보세요.

```
**Protocol Buffers** (or **protobufs** for short) provide their own definition language. Blah, blah, blah. And that's why protobufs have won so many county fairs.
```

처음에 약어를 지정하고 이후부터 약어만을 사용하고 있습니다.

## Use acronyms properly

생소한 약어를 처음 사용할 때에는 전체 용어를 풀어 쓰고, 괄호 안에 넣습니다. 이 때, 전체 용어와 약어 모두를 굴게 표시하여야 합니다. 구 후에는 약어만 사용하도록 합니다. (번갈아서 사용하지 마세요.)

```
If no cache entry exists, the Mixer calls the **OttoGroup Server** (**OGS**) to fetch Ottos for the request. The OGS is a repository that holds all servable Ottos. The OGS is organized in a logical tree structure, with a root node and two levels of leaf nodes. The OGS root forwards the request to the leaves and collects the responses.
```

그렇다면 언제 약어를 사용하는 것이 좋을까요? 비교적 최근에 소개된 약어는 독자가 머릿속에서 변환과정을 거쳐야하므로 오히려 전체 용어보다 읽는 시간이 더 오래 걸릴 수 있습니다. 따라서 몇 번만 사용될 약어는 정의하지 않는 편이 좋습니다. 아래의 조건을 모두 충족시킬 경우에만 정의하세요:

- 약어가 전체 용어보다 상당히 짧음.
- 약어가 문서에 여러 번 나타남.

## Recognize ambiguous pronouns

대명사를 부적절하게 사용하면 혼란스러울 수 있습니다. 대부분의 상황에서 대명사보다 명사를 반복 사용하는 것이 좋습니다.

- 대명사는 해당 명사를 소개한 직후에만 사용하기.
- 대명사는 명사와 가능한 한 가깝게 배치하기.
- 명사와 대명사 사이에 두 번째 명사가 있다면 명사를 반복사용하기.

## Wrap Up

효과적인 기술 문서를 작성하려면 단어 선택과 일관성을 신중하게 고려해야 합니다. 용어 정의, 약어의 적절한 사용, 모호한 대명사의 회피를 통해 문서의 명확성을 높일 수 있습니다.

### 요약

이 문서에서는 독자의 이해를 돕기 위해 새로운 용어나 익숙하지 않은 용어를 정의하는 것의 중요성을 논의했습니다. 문서 전체에서 일관된 용어 사용의 필요성을 강조했습니다. 약어를 명확하게 소개하고 적절하게 사용하는 방법을 강조했습니다. 마지막으로, 모호한 대명사가 초래할 수 있는 혼란을 다루고 이를 피하기 위한 전략을 제안했습니다. 이러한 지침을 따르면 기술 문서의 가독성과 전문성을 향상시킬 수 있습니다.

### Reference

- [Words | Technical Writing | Google for Developers](https://developers.google.com/tech-writing/one/words)

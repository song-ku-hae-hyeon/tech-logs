![Social-Card](/static/img/social-card.png)

# Tech Logs

네카라 개발자 **송구해현**의 스터디 기록 ([바로가기](https://song-ku-hae-hyeon.github.io/tech-logs/))

## Study

### List

현재까지 진행한 스터디 목록입니다.

| Topic                | Schedule      | Reference                                                    |
| -------------------- | ------------- | ------------------------------------------------------------ |
| Technical Writing    | 24.11 ~       | [Link](https://developers.google.com/tech-writing/overview)  |
| Docker               | 24.06 ~ 24.11 | [Link](https://www.yes24.com/Product/Goods/108431011)        |
| Design Pattern       | 24.01 ~ 24.06 | [Link](https://refactoring.guru/ko)                          |
| Chrome Extension     | 23.01 ~ 24.01 | [Link](https://github.com/song-ku-hae-hyeon/BTB)             |
| Haskell              | 22.07 ~ 23.11 | [Link](https://wikidocs.net/book/204)                        |
| Effective Typescript | 22.03 ~ 22.06 | [Link](https://www.yes24.com/Product/Goods/102124327)        |
| JS and Web           | 21.10 ~ 22.02 | [Link](https://github.com/song-ku-hae-hyeon/We-dont-know-JS) |

### Rules

Tech-Logs 에 게시할 글 작성 규칙입니다.

- 레퍼런스와 무관하게 Tech Logs는 스터디 주제에 맞게 정리하는데 의의를 둡니다.
- 원문이 존재하더라도 주제에 맞게 생략 혹은 변경할 수 있습니다.
- 글은 높임말을 기본으로 합니다.
- 대제목은 `title`로 작성 혹은 `h1` 로 작성합니다.
- 중제목(`h2`)과 소제목(`h3`) 을 사용합니다.
- 원문이 존재할 경우 중제목은 되도록 원어에 맞추도록 합니다.
- 기본적으로 문단(`p`)을 사용하여 작성하도록 합니다.
- 참고 문장 혹은 인용 문장은 인용 블록(`blockquote`)를 사용합니다.
- 필요에 따라 `bullet-list`, `numbered-list`, `table` 을 사용합니다.
- 리스트는 되도록 2단이 넘어가지 않도록 주의합니다.
- 글의 마지막에는 레퍼런스를 작성합니다.

```
---
title: 대제목
description: 설명
sidebar_position: 1
tags:
  - Releases
  - docusaurus
---

## 중제목
텍스트

### 소제목
텍스트

## Reference
참고 링크

```

- docusaurus의 마크다운 기능은 [기술 문서](https://docusaurus.io/docs/markdown-features)를 참고해주세요.

## Edit

### Pre-requisites

- Node v22
- Pnpm v9

### Installation

```
$ corepack enable
$ pnpm i
```

### Local

```
$ pnpm run start
```

로컬 개발 서버를 시작하고 브라우저 창을 엽니다.

### Build

```
$ pnpm run build
```

`build` 디렉토리에 결과물이 생성됩니다.

### Deploy

Github Actions 를 이용하여 자동으로 배포되며, `main` 브랜치 push를 트리거 조건으로 합니다.

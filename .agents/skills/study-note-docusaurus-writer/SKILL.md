---
name: study-note-docusaurus-writer
description: 학습 원문을 받아 Docusaurus 문서로 정리하는 스킬. docs 하위 카테고리 추천, title/sidebar_position/tags/reference 수집, md 파일 작성, 최종 검증이 필요할 때 사용한다.
---

# Study Note Docusaurus Writer

학습 내용을 Docusaurus 문서로 일관되게 정리한다.

## 기본 원칙

- 항상 한국어로 답변한다.
- 문장은 기본적으로 높임말로 작성한다.
- 사용자 원문을 최대한 보존한다.
- 사용자 입력 내용 사용 비율을 90% 이상으로 유지한다.
- 사용자 미입력 보충 내용은 전체의 20% 이하로 제한한다.
- 인용 문장과 참고 문장은 `blockquote`를 사용한다.
- 리스트는 2-depth를 넘기지 않는다.
- 원문에 있는 그림 번호, 항목 번호, `❶`, `❷`, `1️⃣` 같은 번호 표기는 의미가 유지되도록 가능한 한 그대로 보존한다.

## 실행 순서

1. 정리할 원문을 받는다.
2. 카테고리를 받는다.
3. 제목(title)을 받는다.
4. `sidebar_position`을 받는다.
5. tags를 받는다.
6. reference를 받는다.
7. 템플릿에 맞춰 md 파일을 작성한다.
8. 요구사항 적합성을 검증한다.

## 질문 순서와 수집 규칙

아래 질문을 이 순서대로 진행한다. 이미 사용자 최초 요청에 포함된 값은 재질문하지 않는다.

1. 정리하려는 원문
2. 카테고리
3. title
4. sidebar number
5. tags
6. reference

## 카테고리 선택 규칙

1. `scripts/list-doc-categories.sh`를 실행하여 `docs` 1depth 폴더를 추천한다.
2. 사용자가 1depth를 고르면 해당 폴더의 2depth 하위 폴더를 다시 추천한다.
3. 2depth가 없거나 새 하위 카테고리를 원하면 카테고리명을 받아 폴더를 생성한다.
4. 새 카테고리 폴더에는 `_category_.json`을 반드시 만든다.

`_category_.json` 템플릿:

```json
{
  "label": "{카테고리 표시명}",
  "position": {번호},
  "link": {
    "type": "generated-index",
    "description": "{카테고리 설명}"
  }
}
```

## title 추천 규칙

1. 사용자 원문을 바탕으로 title 후보 2-3개를 제안한다.
2. 최종 title을 사용자에게 확인받는다.

## sidebar number 추천 규칙

1. `scripts/suggest-sidebar-position.sh <대상_폴더>`를 실행한다.
2. 기존 문서들의 `sidebar_position`을 파싱해 추천 번호를 제시한다.
3. 사용자가 최종 번호를 확정한다.

## tags 추천 및 추가 규칙

1. `scripts/list-tags.sh`를 실행해 `docs/tags.yml` 기반 태그를 추천한다.
2. 사용자가 없는 태그를 입력하면 permalink를 질문한다.
3. 새 태그를 `docs/tags.yml`에 추가한다.

태그 추가 템플릿:

```yml
{ tag-key }:
  label: "{표시명}"
  permalink: "{permalink}"
  description: "Docs related to {표시명}"
```

## reference 규칙

1. 기본 레퍼런스를 카테고리 기준으로 자동 포함한다.
2. 사용자에게 추가 레퍼런스가 있는지 질문한다.
3. 추가 레퍼런스가 있으면 제목과 링크를 함께 받는다.

기본 레퍼런스:

- `unit-test` 하위 카테고리: [단위 테스트의 기술](https://www.gilbut.co.kr/book/view?bookcode=BN004314)
- `technical-writing` 하위 카테고리: [List and Tables | Technical Writing | Google for Developers](https://developers.google.com/tech-writing/one/list-and-tables)
- `large-scale-services` 하위 카테고리: [대규모 서비스를 지탱하는 기술](https://www.yes24.com/Product/Goods/4667932)

## 문서 작성 규칙

1. `assets/docusaurus-note-template.md`를 기반으로 작성한다.
2. 원문이 있어도 주제 적합성을 위해 일부 생략/재구성할 수 있다.
3. 원문에 `#` 헤더가 있으면 텍스트는 헤더로 유지한다.
4. 원문에 이미지 파일명이 있으면 frontmatter 아래에 import를 추가한다.
5. 본문 이미지는 `<img src={Image01} width={480} />` 형태로 사용한다.
6. 본문 마지막에는 `Wrap Up`, `Summary`, `Reference`를 반드시 작성한다.
7. 그림 설명이나 본문에 번호 참조가 있으면 문장을 다듬더라도 해당 번호 표기를 임의로 일반화하거나 삭제하지 않는다.

이미지 import 형식:

```mdx
import Image01 from "./img/{사용자_언급_파일명}";
```

## 파일 작성 절차

1. 대상 경로와 파일명을 확정한다.
2. md 또는 mdx 확장자를 선택한다. 이미지 import가 있으면 mdx를 우선한다.
3. 메타데이터를 먼저 작성한다.
4. 본문을 작성한다.
5. Reference 목록을 마지막에 배치한다.

## 최종 검증

`scripts/validate-note.sh <작성한_파일_경로>`를 실행하고, 아래를 수동으로 재확인한다.

- frontmatter에 `title`, `description`, `sidebar_position`, `tags`가 있는가
- 본문이 사용자 입력 기반으로 구성되었는가
- 사용자 입력 반영 비율이 90% 이상인가
- 보충 내용이 20% 이하인가
- 원문에 있던 그림 번호, 항목 번호, 기호 번호 표기가 유지되었는가
- `Wrap Up`과 `Summary`가 본문을 정확히 요약하는가
- 문서 하단에 `Reference`가 리스트 형태로 있는가
- 문체가 존댓말인가

검증 실패 시 즉시 수정 후 재검증한다.

---
title: 브리지 패턴
description: 브리지 패턴은 큰 클래스 계층을 추상화와 구현의 두 축으로 나누어 독립적으로 확장할 수 있게 합니다.
sidebar_position: 2
tags:
  - design-pattern
---

> 브리지는 큰 클래스 또는 밀접하게 관련된 클래스들의 집합을 두 개의 개별 계층구조(추상화 및 구현)로 나눈 후 

> 각각 독립적으로 개발할 수 있도록 하는 구조 디자인 패턴입니다.

## 의미

### 배경

- 객체의 차원이 다양해 질 경우 계층 구조가 복잡해짐.
- 책에서는 `Shape` 를 예제로 들고 있습니다. 모양 하위에 원과 사각형이 있다고 할 때, 각각에 색상 red, blue를 주고 싶습니다.
- 원 하위에 빨간 원, 파랑 원 클래스, 사각형 하위에 빨간 사각형, 파랑 사각형 클래스가 생김.
- 만약 이 상태에서 삼각형을 추가 하고 싶다면? 거기서 또 다른 색상이 생긴다면? 각 유형 별로 각 색상까지 기하급수적으로 클래스가 늘어남.

### 해결

- 위의 예시에서 차원은 모양과 색상으로 난눌 수 있습니다.
- 브리지 패턴은 상속이 아닌 객체 합성으로 문제를 해결.
- 차원을 별도 클래스 계층 구조로 추출하고 참조 형태도 변경.

### 구조

<img width="300" alt="image" src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/71266602/a899e391-b357-433b-b481-2705890be5aa" />
- "추상화"와 "구현"이라는 단어를 사용합니다. (프로그래밍에서의 인터페이스와 추상클래스는 아닙니다.)
- 추상화는 상위 수준의 로직을 담당하며 구현 객체에 의존하여 하위 수준 작업들을 수행.
- 구현은 모든 구상 구현들에 공통적 인터페이스 제공. 추상화는 여기 선언된 메서드들을 조합하여 상위 수준 로직 수행.
- 구상된 구현들에는 플랫폼별 혹은 상황별 등 맞춤형 코드가 들어있습니다.
- Refined Abstraction은 로직의 변형. 더 다양한 기능을 제공하기 위한 선택사항.
- 클라이언트는 구현 객체들 중 하나를 추상화에 연결하여 추상화와만 작업.

## 코드

### Concept

```ts

/**
 * 추상화로 첫 번째 차원 정의.
 * 리스트를 출력해주는 클래스
 * 초기화 단계에서 구현 객체를 장착.
 */
abstract class ListItemViewAbstraction {
    constructor(protected contentType: ContentTypeImplementation) {
    }

    abstract getRenderedItem(): string;
}

/** 
 * 구현으로 두 번째 차원 정의.
 * 다양한 컨텐츠 타입이 가져야할 저수준의 메소드 정의
 * 모든 구상 구현 클래스들에 대한 공통적인 메서드를 선언하여 인터페이스 구성.
 */
interface ContentTypeImplementation {
    renderTitle(): string;
    renderCaption(): string;
    renderThumbnail(): string;
    renderLink(): string;
}

/** 
 * 첫 번째 차원의 확장 (사각형, 원이 되었던 것과 같음.)
 * 컨텐츠 타입의 메소드들을 조합하여 고수준의 로직 수행
 */
class VisualListItemView extends ListItemViewAbstraction {
    getRenderedItem(): string {
        return `    <li>
        ${this.contentType.renderThumbnail()}
        ${this.contentType.renderLink()}
    </li>`;
    }
}

class DescriptiveListItemView extends ListItemViewAbstraction {
    getRenderedItem(): string {
        return `    <li>
        ${this.contentType.renderTitle()}
        ${this.contentType.renderCaption()}
    </li>`;
    }
}

/**
 * 구현 인터페이스를 따르는 컨텐츠 타입 클래스
 */
class VideoContentType implements ContentTypeImplementation {
    constructor(
        protected title,
        protected description,
        protected thumbnailUrl,
        protected url) {}

    renderTitle(): string {
        return `<h2>${this.title}<h2>`;
    }
    renderCaption(): string {
        return `<p>${this.description}</p>`;
    }
    renderThumbnail(): string {
        return `<img alt='${this.title}' src='${this.thumbnailUrl}'/>`;
    }
    renderLink(): string {
        return `<a href='${this.url}'>${this.title}</a>`;
    }
}

class TweetContentType implements ContentTypeImplementation {
    constructor(
        protected tweet,
        protected profilePictureUrl,
        protected tweetUrl) {}

    renderTitle(): string {
        return `<h2>${this.tweet.substring(0, 50)}...<h2>`;
    }
    renderCaption(): string {
        return `<p>${this.tweet}</p>`;
    }
    renderThumbnail(): string {
        return `<img alt='${this.tweet.substring(0, 50)}...' src='${this.profilePictureUrl}'/>`;
    }
    renderLink(): string {
        return `<a href='${this.tweetUrl}'>${this.tweet.substring(0, 30)}...</a>`;
    }
}


const tweetContentType =  new TweetContentType(
  'Windows will support Linux executables natively on Windows 12',
  'http://img.sample.org/profile.jpg',
  'https://twitter.com/genbeta/387487346856/',
);

const videoContentType = new VideoContentType(
    'BRIDGE | Patrones de Diseño',
    'En éste vídeo de la serie de PATRONES DE DISEÑO veremos el PATRÓN BRIDGE!',
    'http://img.sample.org/bridge.jpg',
    'https://www.youtube.com/watch?v=6bIHhzqMdgg',
)

const tweetVisualListItemView = new VisualListItemView(tweetContentType);
console.log(tweetVisualListItemView.getRenderedItem());

const videoDescriptiveListItemView = new DescriptiveListItemView(videoContentType);
console.log(videoDescriptiveListItemView.getRenderedItem());

```

1. 차원을 식별. (추상화/플랫폼, 도메인/인프라, 프론트/백엔드 등. 여기서는 추상화/플랫폼)
2. 클라이언트에서 필요한 작업을 확인하고 기초 추상 클래스를 정의.
3. 모든 플랫폼에서 제공되어야 하는 작업을 결정하고 구현 인터페이스 선언.
4. 구상 구현 클래스 생성.
5. 추상화 클래스에서는 구현 유형을 참조하도록 작성.
6. 상위 수준 로직 변형이 여러개라면 기초 추상화 클래스를 확장하여 refined Abstraction(정제된 추상화) 작성
7. 클라이언트 코드는 구현 객체를 추상화에 전달하여 구현은 잊고 추상화 객체로만 작업.

### Use Case
- 테마 별로 다양한 컴포넌트를 제공할 때 사용할 수 있을 것 같습니다.
- MUI를 예로 들면 추상화는 컴포넌트, 구현은 테마.
- 실제로 MUI를 사용할 때, 테마를 아래와 같이 생성할 수 있습니다.

```tsx
const theme = createTheme({
  status: {
    danger: orange[500],
  },
});
```

- 이 때, `createTheme`을 통해 구현 객체를 생성했다고 볼 수 있을 것 같습니다.
- 추상화 객체인 컴포넌트들은 `theme.palette.secondary.main` 와 같은 방식으로 테마를 사용하게됩니다.

```tsx
<ThemeProvider theme={theme}>
  {...}
</ThemeProvider>
```

- 실제로 FE개발에서 구현 객체인 `theme`을 `ThemeProvider`라는 브릿지를 통해 추상화에 전달하게 되고, FE개발자들은 추상화 객체인 UI컴포넌트 들로만 작업.

## 장단점

### 장점

- 추상화와 구현을 분리함으로써 각각 독립적으로 변형 및 확장이 가능.
- 구현 세부 정보를 노출시키지 않을 수 있습니다.

### 단점

- 간단한 SW에 브리지 패턴을 적용하면 오히려 설계가 복잡해질 수 있습니다.
- 결합도가 매우 높은 클래스에 적용하려고 시도하면 오히려 코드가 복잡해질 수 있습니다.

## Wrap Up
브리지 패턴은 Structural Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
브리지 패턴은 큰 클래스 계층을 추상화와 구현의 두 축으로 나누어 독립적으로 확장할 수 있게 합니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)

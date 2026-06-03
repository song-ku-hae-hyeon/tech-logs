---
title: 플라이웨이트 패턴
description: 플라이웨이트 패턴은 많은 객체가 공유할 수 있는 상태를 분리하여 메모리 사용을 줄이는 구조 패턴입니다.
sidebar_position: 6
tags:
  - design-pattern
---

## Concept

- Fly는 "가볍다/무겁지 않다"라는 뜻입니다
- 공통 속성을 공유하는 수천 개의 객체를 생성하는 대신 공통 속성을 공유함으로써 메모리를 효율적으로 관리할 수 있게 하는 디자인 패턴
- 예시
  - 많은 단어와 문장이 포함되어 있고 많은 문자로 구성된 문서
  - 글꼴, 위치, 색상, 패딩 및 기타 여러 가지 가능성을 설명하는 각 개별 문자에 대해 새 객체를 저장하는 대신
  - 문자의 조회 ID만 일종의 컬렉션에 저장한 다음 필요할 때만 적절한 서식 등으로 개체를 동적으로 생성합니다

## Terms

- 내재적 속성 (intrinsic attributes)
  - 다른 플라이웨이트와 구별되는 고유한 속성
  - 알파벳 문자
- 외재적 속성 (extrinsic attributes)
  - 사용될 컨텍스트의 관점에서 플라이웨이트를 표현하는 데 사용되는 속성
  - 각 문자의 X Y 축에 대한 위치 속성

### 구현 방법

1. 플라이웨이트가 될 클래스의 필드를 두 부분으로 나눔
2. 클래스의 고유한 상태를 나타내는 필드는 그대로 두고 불변한 상태로 만듦
3. 공유하는 상태의 필드를 사용한 메서드 내에 필드를 제거하고 매개변수로 추가
4. 플라이웨이트 풀 관리를 위한 팩토리 클래스 생성합니다

### 구조 및 예시

<img width="500" alt="image" src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/73208317/803b394f-5040-4569-bd4a-e8c250983e3b" />
```ts
interface IFlyweight {
  code: number;
}

class Flyweight implements IFlyweight {
  code: number;
  constructor(code: number) {
    this.code = code;
  }
}

class FlyweightFactory {
  static flyweights: { [id: number]: Flyweight } = {};

  static getFlyweight(code: number): Flyweight {
    if (!(code in FlyweightFactory.flyweights)) {
      FlyweightFactory.flyweights[code] = new Flyweight(code);
    }
    return FlyweightFactory.flyweights[code];
  }

  static getCount(): number {
    return Object.keys(FlyweightFactory.flyweights).length;
  }
}

class AppContext {
  private codes: number[] = [];

  constructor(codes: string) {
    for (let i = 0; i < codes.length; i++) {
      this.codes.push(codes.charCodeAt(i));
    }
  }

  output() {
    return this.codes.reduce(
      (acc, cur) =>
        acc + String.fromCharCode(FlyweightFactory.getFlyweight(cur).code),
      ""
    );
  }
}

const APP_CONTEXT = new AppContext("abracadabra");

console.log(APP_CONTEXT.output());
console.log(`abracadabra has ${"abracadabra".length} letters`);
console.log(`FlyweightFactory has ${FlyweightFactory.getCount()} flyweights`);
```

### recap

- 클라이언트는 플라이웨이트 오브젝트가 공유되도록 하기 위해 `플라이웨이트팩토리` 오브젝트 통해서만 플라이웨이트 오브젝트에 접근해야 합니다.
- 내재적 속성은 플라이웨이트 내부에 저장 / 외재적 속성은 플라이웨이트에 전달되어 컨텍스트에 따라 변경
- 장점 : 플라이웨이트는 객체를 공유하고 동적으로 외래 속성을 생성할 수 있기 때문에 메모리 사용 공간 절약
- 단점 : 플라이웨이트에 외생 값을 계산하고 전달하는 동안 추가 CPU가 필요할 수 있습니다
- 플라이웨이트 구현 시 모든 객체를 메모리에 저장하는 것과 작은 고유 부분을 메모리에 저장하고 잠재적으로 컨텍스트 객체에서 외래 값을 계산하는 것 사이에서 균형을 잡는 것
- 플라이웨이트 아키텍처 설계 시 먼저 공통 객체에서 어떤 부분을 분할하여 외적 속성을 사용하여 적용할 수 있는지 고려

### Refs

- https://sbcode.net/typescript/flyweight/
- https://refactoring.guru/design-patterns/flyweight
- https://www.geeksforgeeks.org/flyweight-design-pattern/

## Wrap Up
플라이웨이트 패턴은 Structural Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
플라이웨이트 패턴은 많은 객체가 공유할 수 있는 상태를 분리하여 메모리 사용을 줄이는 구조 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)

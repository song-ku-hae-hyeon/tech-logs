---
title: 프로토타입 패턴
description: 프로토타입 패턴은 클래스에 직접 의존하지 않고 기존 객체를 복제하여 새 객체를 만드는 생성 패턴입니다.
sidebar_position: 4
tags:
  - design-pattern
---

- 클래스에 의존시키지 않고 기존 객체들을 복사할 수 있도록 하는 생성 디자인 패턴
- 프로토타입은 복제를 지원하는 객체를 의미합니다
- 디자인 패턴으로서의 프로토타입은 이미 존재하는 객체를 효율적으로 복사하기 위한 방법론의 일종입니다.
- 반면, 자바스크립트의 프로토타입은 상위 객체의 프로퍼티를 하위 객체가 상속받기 위해 사용하는 자바스크립트의 고유 기능입니다.

## 문제

- A 객체의 정확한 복사본을 만들고 싶다면?
  - A 객체 생성에 사용한 클래스로 새로운 B 객체 생성합니다
  - A 기존 객체의 필드들을 살펴본 후 B 객체에 복사합니다
- 항상 가능하지는 않습니다
  - 객체의 필드 중 일부가 비공개일 수 있기 때문입니다
  - 객체를 복사하고 싶을 뿐인데 클래스에 의존해야 합니다
    - 클래스 생성자에 필요한 파라미터를 알아야 합니다

## 해결책

- 프로토타입 패턴은 복제되는 객체에 복제 프로세스를 위임합니다
  - 문제에서 예시로 든 A 객체
- 복제를 지원하는 모든 객체에 대한 공통 인터페이스를 선언합니다. 이를 통해 객체의 클래스에 결합하지 않고 해당 객체를 복제할 수 있습니다.
  - 일반적으로 인터페이스에는 단일 `clone` 메서드만 포함됩니다
- `clone` 메서드는 현재 클래스의 객체를 만든 후 이전 객체의 모든 필드 값을 새 객체로 전달합니다
- 객체에 수십 개의 필드와 가능한 설정이 존재하는 경우 서브클래싱 대신 프로토타입 패턴을 사용할 수 있습니다

## 구조

1. 프로토타입 인터페이스는 복제 메서드를 선언합니다
2. 구상 프로토타입 클래스가 복제 메서드를 구현합니다. 객체의 데이터 복사 외에도 복제 프로세스와 관련된 일부 예외적인 경우들도 처리할 수 있습니다. 예: 연결된 객체 복제, 재귀 종속성 풀기
3. 클라이언트는 프로토타입 인터페이스를 따르는 모든 객체의 복사본을 생성할 수 있습니다

## 적용

- 복사해야 하는 객체들의 구상 클래스들에 코드가 의존하면 안 될 때 사용합니다
  - 타사 코드에서 전달된 객체들과 함께 작동할 때 발생합니다
    - 접근이 제한적이기 때문에 해당 클래스들에 의존하기 어렵습니다
  - `clone` 인터페이스는 클라이언트 코드가 복제하는 객체의 구상 클래스들에서 클라이언트 코드를 독립시킵니다
- 각각의 객체를 초기화하는 방식만 다른 자식 클래스들(서브 클래싱)의 수를 줄이고 싶을 때 사용합니다

## 구현 방법

1. 프로토타입 인터페이스를 생성하고 그 안에 `clone` 메서드를 선언합니다
2. 프로토타입 클래스
   - 클래스 객체를 인수로 받는 대체 생성자 정의. 대체 생성자는 새로 생성된 인스턴스로 복사해야 합니다.
   - 프로그래밍 언어가 오버로딩을 지원하지 않으면 별도의 '프로토타입' 생성자를 만들 수 없습니다.
     - 객체의 데이터를 새로 생성된 복제본에 복사하는 작업은 `clone` 메서드 내에서 수행되어야 합니다.
     - 그래도 일반적인 생성자에 두는 것보다는 안전합니다. new 연산자를 호출한 직후에 생성된 객체는 완전히 설정된 상태이기 때문입니다
3. 복제 메서드 실행
   - 생성자의 프로토타입 버전으로 new 연산자를 실행합니다
   - 복제 메서드를 오버라이딩한 후 new 연산자와 함께 자체 클래스 이름을 사용합니다
4. 프로토타입의 카탈로그를 저장할 중앙 프로토타입 레지스트리 생성할 수 있습니다

## 장단점

- 객체가 구상 클래스들에 결합하지 않고 복제할 수 있습니다
- 복잡한 객체에 대한 사전 설정을 처리할 때 상속 대신 사용할 수 있습니다
- 복잡한 객체를 쉽게 생성합니다
- 순환 참조가 있는 복잡한 객체를 복제하는 것은 매우 까다로울 수 있습니다

## 예제 코드

```ts
export interface Cloneable<T> {
  clone(): T;
}

export class ComponentPrototype implements Cloneable<ComponentPrototype> {
  clone(): ComponentPrototype {
    return { ...this };
  }
}
```

```ts
export class Document extends ComponentPrototype {
  components: ComponentPrototype[] = [];

  clone(): Document {
    const clonedDocument = new Document();
    clonedDocument.components = this.components.map((c) => c.clone());
    return clonedDocument;
  }

  add(component: ComponentPrototype) {
    this.components.push(component);
  }
}

export class Title extends ComponentPrototype {
  constructor(public text: string) {
    super();
  }

  setText(text: string) {
    this.text = text;
  }
}

export class Drawing extends ComponentPrototype {
  constructor(public shape: "circle" | "square" | "line") {
    super();
  }

  setShape(shape: "circle" | "square" | "line") {
    this.shape = shape;
  }
}
```

```ts
/**
 * The client code.
 */
const document = new Document();
const title = new Title("Example Domain");

document.add(title);
document.add(new Drawing("line"));

const clonedDocument = document.clone();
title.setText("New title for the original document");

console.log("document is:");
console.log(document);
console.log("clonedDocument is:");
console.log(clonedDocument);
```

## 참고 자료

- [message box example](https://velog.io/@ninthsun91/Typescript%EB%A1%9C-%EB%8B%A4%EC%8B%9C-%EC%93%B0%EB%8A%94-GoF-Prototype)
- [nodejs example](https://medium.com/@diegomottadev/exploring-prototype-design-pattern-implementation-with-typescript-and-node-js-b2683fcd29b7)

## Wrap Up
프로토타입 패턴은 Creational Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
프로토타입 패턴은 클래스에 직접 의존하지 않고 기존 객체를 복제하여 새 객체를 만드는 생성 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)

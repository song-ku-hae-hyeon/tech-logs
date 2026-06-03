---
title: 싱글턴 패턴
description: 싱글턴 패턴은 클래스의 인스턴스를 하나로 제한하고 전역 접근 지점을 제공하는 생성 패턴입니다.
sidebar_position: 5
tags:
  - design-pattern
---

Singleton 라고도 불림.

> 클래스에 인스턴스가 하나만 있도록 하면서 이 인스턴스에 대한 전역 접근 지점을 제공하는 생성 디자인 패턴.

## 문제

싱글턴 패턴은 한 번에 두 가지 문제를 동시에 해결함으로써 *단일 책임 원칙을 위반합니다.

> 단일 책임 원칙 : 모든 클래스는 하나의 책임만 가지며, 클래스는 그 책임을 완전히 캡슐화해야 합니다

1. 클래스에 인스턴스가 하나만 있도록 합니다.
  - 하나만 만드는 이유? 공유 리소스(DB or file)에 대한 접근을 제어하기 위해
2. 해당 인스턴스에 대한 전역 접근 지점을 제공.
  - 전역변수로 정의하면 관리가 어렵습니다. 잠재적으로 변수를 덮어쓸 수 있기 때문입니다.
  - 모든 곳에서 접근은 할 수 있지만, 인스턴스를 덮어쓰지 못하도록 보호해야 합니다.

> 최근에는 싱글턴 패턴이 워낙 대중화되어 패턴이 나열된 문제 중 한 가지만 해결하더라도 그것을 싱글턴이라고 부를 수 있습니다. (난잡해진 싱글턴 세상에 교통정리를 해주는 느낌)

## 해결책

- new 연산자를 사용하지 못하도록 디폴트 생성자를 비공개로 설정
- 생성자 역할을 하는 정적 생성 메서드 생성. 여기서 비공개 생성자를 호출한 후 객체를 정적 필드에 저장. 그다음 호출부터 모두 캐시된 객체를 반환.

## 구현

```ts
class Singleton {
  private static instance: Singleton;

  private constructor() {
    // do initialization
  }

  public static getInstance(): Singleton {
    if (!Singleton.instance) { // 멀티스레딩을 지원하는 앱은 여기에 스레드 잠금을 설정해야 합니다. 
      Singleton.instance = new Singleton(); // 지연된 초기화라고 함. (Lazy initialization and Eager initialization, 아래 링크 참고)
    }
    return Singleton.instance;
  }

  public someMethod(): void {
    console.log("Singleton method called");
  }
}

// Usage:
const instance1 = Singleton.getInstance();
const instance2 = Singleton.getInstance();

console.log(instance1 === instance2); // Output: true

instance1.someMethod(); // Output: "Singleton method called"
```

[코드 참고](https://medium.com/front-end-world/design-pattern-singleton-typescript-examples-f775a07d6282)
[Lazy init and Eager init](https://www.linkedin.com/pulse/two-types-singleton-design-pattern-lazy-eager-arifuzzaman-tanin#:~:text=Lazy%20initialization%20provides%20on-demand,even%20if%20it's%20not%20used.)

> Lazy initialization provides on-demand instance creation, which can save resources if the instance is not always required. On the other hand, eager initialization ensures that the instance is always available but may consume resources even if it's not used

[멀티스레딩(JAVA) 참고](https://seunghyunson.tistory.com/28)

> 여러 개의 쓰레드가 동시에 getInstance() 메소드에 접근한다고 할 때 여러 개의 인스턴스가 만들어질 수도 있는 상황이 발생할 수 있기 때문입니다.
JAVA에는 싱글턴을 구현하는 여러 방식이 있습니다. 
- synchronized keyword
- DCL(Double checked locking)
- violate keyword
- static 초기화(Eager init으로 동시성을 피하는 방법)
- LazyHolder
- ENUM

## 적용

- 모든 클라이언트가 사용할 수 있는 단일 인스턴스만 있어야 할 때 사용 (e.g. 단일 데이터베이스 객체)
- 특별 생성 메서드(첫 초기화를 위한)를 제외하고는 클래스의 객체들을 생성할 수 있는 모든 다른 수단들을 비활성화합니다.
    - 접근자와 static으로 구현합니다
- 전역 변수들을 더 엄격하게 제어해야 할 때 사용합니다
    - 일반적인 전역 변수들은 변경이 가능하기 때문

> 이 제한은 언제든 조정 가능하고 원하는 수만큼의 싱글턴 인스턴스 생성을 허용할 수 있습니다. 그러기 위해서 변경해야 하는 코드의 유일한 부분은 getInstance() 뿐입니다.
DB Connection pool이 이런 메커니즘일듯??

## 장단점

- 클래스가 하나의 인스턴스만 갖는다는 것을 확신할 수 있습니다.
- 이 인스턴스에 대한 전역 접근 지점을 얻습니다.
- 처음 요청될 때만 초기화됩니다. (혹은 처음 프로그램이 실행될 때)
- 단일 책임 원칙을 위반. 이 패턴은 한 번에 두 가지의 문제를 동시에 해결함. 
    - 해결 하려는게 하나의 인스턴스, 전역접근 으로 봐야할지..?
- 잘못된 디자인을 가릴 수 있습니다. (e.g. 프로그램의 컴포넌트들이 서로에 대해 너무 많이 알고 있는 경우)
- 다중 스레드 환경에서 여러 스레드가 싱글턴 객체를 여러 번 생성하지 않도록 특별한 처리가 필요
- 싱글턴의 클라이언트 코드를 유닛 테스트하기 어려울 수 있습니다.
    - 많은 테스트 프레임워크들이 모의 객체들을 생성할 때 상속에 의존
    - 싱글턴 클래스의 생성자는 비공개
    - 대부분 언어에서 정적 메서드를 오버라이딩하는 것이 불가능합니다

## Wrap Up
싱글턴 패턴은 Creational Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
싱글턴 패턴은 클래스의 인스턴스를 하나로 제한하고 전역 접근 지점을 제공하는 생성 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)

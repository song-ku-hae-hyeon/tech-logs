---
title: 팩토리 메서드 패턴
description: 팩토리 메서드 패턴은 부모 클래스에서 객체 생성 인터페이스를 제공하고, 자식 클래스가 생성할 제품 유형을 바꿀 수 있게 하는 생성 패턴입니다.
sidebar_position: 1
tags:
  - design-pattern
---

가상 생성자, Factory method라고도 불림.

> 부모 클래스에서 객체들을 생성할 수 있는 인터페이스를 제공하지만, 자식 클래스들이 생성될 객체들의 유형을 변경할 수 있도록 하는 생성 패턴입니다.

## 문제

- 물류 관리 앱을 개발중
- 첫 버전은 트럭 운송만 처리 가능 (Truck 클래스)
- 두 번째 버전에서 선박 운송이 필요 (Ship 클래스)
- n 번재 버전에 운송 수단이 계속 추가됩니다.
- 이는 전체 코드 베이스를 변경해야하는 이유가 됩니다
  - 조건문으로 운송 수단 객체들의 클래스에 따라 행동을 바꾸는 코드가 곳곳에 필요할 것입니다.

## 해결책

객체 생성 직접 호출들을 특별한 팩토리 메서드에 대한 호출들로 대체하라고 제안합니다.

팩토리 메서드에서 반환된 객체는 종종 제품이라고도 불림.

RoadLogistics, SeaLogistics는 Logistics를 상속받습니다. createTransport()에서 생성되는 제품들의 클래스를 변경할 수 있게 됩니다.

![KakaoTalk_Image_2024-02-18-14-01-41_002](https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/50704533/3007590d-c42a-4e94-9a5c-46330c9601c3)

패턴에 구현에 제한이 있습니다. 자식 클래스들(RoadLogis, SeaLogis)은 다른 유형의 제품들을 해당 제품들이 공통 기초 클래스 또는 공통 인터페이스가 있는 경우(Transport)에만 반환할 수 있습니다.

![KakaoTalk_Image_2024-02-18-14-01-41_001](https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/50704533/73305b05-0206-4c84-8506-8f36942f3ade)

클라이언트 코드(팩토리 메서드를 사용하는 코드)는 다양한 자식 클래스들에서 실제로 반환되는 여러 제품간의 차이에 대해 알지 못합니다. 클라이언트 코드는 모든 제품을 deliver 메서드를 가진 추상 Transport로 간주하며, 어떻게 동작하는지는 중요치 않습니다.

제품은 인터페이스(Transport)를 선언합니다. 인터페이스는 생성자와 자식 클래스들이 생성할 수 있는 모든 객체에 공통으로 적용됩니다.

생성자 클래스는 새로운 제품 객체들을 반환하는 팩토리 메서드(createTransport)를 선언. 이 메서드의 반환 유형이 제품 인터페이스와 일치해야 합니다.

팩토리 메서드를 추상으로 선언하거나 기본값 제품 유형을 반환하도록 만들 수도 있습니다.

크리어에터라는 이름에도 불구하고 크리에이터의 주책임은 제품을 생성하는 것이 아닙니다. 일반적으로 이미 제품과 관련된 핵심 비즈니스 로직이 있으며, 이 로직을 구상 제품 클래스들(Truck, Ship)로부터 디커플링 하는 데 도움을 줄 뿐입니다.

구상 크리에이터들(RoadLogis, SeaLogis)은 기초 팩토리 메서드를 오버라이드(재정의)하여 다른 유형의 제품을 반환하게 하도록 합니다.

## 구현

```ts
interface Button {
  render();
  onClick(fn);
}

class WindowsButton implements Button {
  clickFn;

  render() {
    console.log("renders a button with Windows style");
  }
  onClick(fn) {
    this.clickFn = fn;
  }
}

class HTMLButton implements Button {
  render() {
    console.log("renders a button with HTML style");
  }
  onClick(fn) {
    // do stuff
  }
}

abstract class Dialog {
  abstract createButton(): Button;

  render() {
    const okButton: Button = this.createButton();
    okButton.onClick(this.closeDialog);
    okButton.render();
  }

  closeDialog() {
    console.log("closeDialog");
  }
}

class WindowsDialog extends Dialog {
  createButton(): Button {
    return new WindowsButton();
  }
}

class WebDialog extends Dialog {
  createButton(): Button {
    return new HTMLButton();
  }
}

class Application {
  dialog: Dialog;

  initialize() {
    if (config.OS == "Windows") {
      this.dialog = new WindowsDialog();
    } else if (config.OS == "Web") {
      this.dialog = new WebDialog();
    } else {
      throw new Error("Error! Unknown operating system.");
    }
  }

  main() {
    this.initialize();
    this.dialog.render();
  }
}

new Application().main();

// 가장 중요한 점은 추상 메서드가 반환하는 타입과 제품들이 구현하는 타입이 같아야 한다는 점.
```

## 적용

- 함께 동작해야 하는 객체들의 정확한 유형들과 의존관계들을 미리 모르는 경우 사용합니다
  - 사용하는 DB의 종류가 바뀔 가능성이 있을 때 [참고](https://stackoverflow.com/a/2386140)
- 제품 생성 코드를 제품을 실제로 사용하는 코드와 분리. 그러면 제품 생성자 코드를 나머지 코드와는 독립적으로 확장하기 쉬워짐.
  - 새로운 제품을 추가하려면, 새로운 크리에이터 자식 클래스를 생성한 후 해당 클래스 내부의 팩토리 메서드를 오버라이딩(재정의)하기만 하면 됩니다.
- 라이브러리 또는 프레임워크의 사용자들에게 내부 컴포넌트들을 확장하는 방법을 제공하고 싶을 때 사용합니다
  - DI의 개념에 팩토리 메서드 패턴을 사용함. [참고](https://www.baeldung.com/spring-framework-design-patterns#factory)
  - 상속은 아마도 라이브러리나 프레임워크의 디폴트 행동을 확장하는 가장 쉬운 방법일 것입니다.

## 장단점

- 크리에이터와 구상 제품들이 단단하게 결합되지 않도록 할 수 있습니다.
- 단일 책임 원칙, 제품 생성 코드를 프로그램의 한 위치로 이동하여 코드를 더 쉽게 유지관리할 수 있습니다.
- 개방/폐쇄 원칙, 기존 클라이언트 코드를 훼손하지 않고 새로운 유형의 제품들을 프로그램에 도입할 수 있습니다.
- 패턴을 구현하기 위해 많은 새로운 자식 클래스들을 도입해야 하므로 코드가 더 복잡해질 수 있습니다. 가장 좋은 방법은 크리에이터 클래스들의 기존 계층구조에 패턴을 도입(팩토리 메서드에 전달인자를 도입)하는 것입니다.

## Wrap Up
팩토리 메서드 패턴은 Creational Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
팩토리 메서드 패턴은 부모 클래스에서 객체 생성 인터페이스를 제공하고, 자식 클래스가 생성할 제품 유형을 바꿀 수 있게 하는 생성 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)

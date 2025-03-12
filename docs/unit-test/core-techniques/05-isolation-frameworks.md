---
title: 격리 프레임워크
description: 격리 프레임워크를 살펴보고 이를 통해 mock과 stub을 작성합니다.
sidebar_position: 3
tags:
  - unit-test
---

이전 장에서는 목과 스텁을 수동으로 직접 작성하는 방법을 살펴보았습니다. 이 장에서는 좀 더 우아한 방식으로 작성하기 위해 격리 프레임워크를 공부합니다.

격리 프레임워크란 런타임에 가짜 객체를 생성하고 설정할 수 있는 재사용 가능한 라이브러리를 의미합니다. 이러한 객체는 동적 스텁(dynamic stubs)과 동적 목(dynamic mocks)이라고 합니다.

## 1. 격리 프레임워크 정의

> 격리 프레임워크는 객체나 함수 형태의 목이나 스텁을 동적으로 생성, 구성, 검증할 수 있게 해주는 프로그래밍 가능한 API다. 격리 프레임워크를 사용하면 이러한 작업을 수작업으로 했을 때보다 더 간단하고 빠르며 코드도 더 짧게 작성할 수 있다.

저자는 위와 같이 격리 프레임워크를 정의하고 있습니다. 하지만 이를 잘못 적용하면 프레임워크를 남용하게 되어 테스트를 읽을 수도 없고 신뢰할 수도 없는 상황에 이를 수 있으니 주의해야 합니다.

### 선택하기: 느슨한 타입 vs 정적 타입

자바스크립트가 다양한 프로그래밍 패러다임을 지원하는 덕분에 격리 프레임워크를 두 가지 유형으로 나눌 수 있습니다.

- 느슨한 타입의 자바스크립트 격리 프레임워크: 이 유형은 순수 자바스크립트 친화적인 느슨한 타입의 격리 프레임워크(jest 등)입니다. 이러한 프레임워크는 일반적으로 작업을 수행할 때 설정과 보일러 플레이트 코드가 더 적게 필요하기 때문에 함수형 스타일 코드에 적합합니다.
- 정적 타입의 자바스크립트 격리 프레임워크: 이 유형은 더 객체 지향적이고 타입스크립트 친화적인 격리 프레임워크(substitute.js 등)입니다. 이러한 프레임워크는 전체 클래스와 인터페이스를 다룰 때 매우 유용합니다.

## 2. 동적으로 가짜 모듈 만들기

다음 예제는 로거 모듈에 강하게 의존하는 비밀번호 검증기 코드입니다.

```jsx
const { info, debug } = require("./complicated-logger");
const { getLogLevel } = require("./configuration-service");

const log = (text) => {
  if (getLogLevel() === "info") {
    info(text);
  }
  if (getLogLevel() === "debug") {
    debug(text);
  }
};

const verifyPassword = (input, rules) => {
  const failed = rules
    .map((rule) => rule(input))
    .filter((result) => result === false);

  if (failed.length === 0) {
    log("PASSED");
    return true;
  }
  log("FAIL");
  return false;
};
```

위 예제를 테스트하기 위해 두 가지 작업을 수행해야 합니다.

- 구성 서비스의 getLogLevel() 함수에서 반환하는 값을 스텁을 사용하여 가짜로 만들어야 합니다.
- Logger 모듈의 info() 함수가 호출되었는지 모의 함수를 사용하여 검증해야 합니다.

Jest는 목을 만들고 검증할 수 있는 몇 가지 방법을 제시하는데, 그중 하나는 테스트 파일의 가장 위쪽에 `jest.mock([module-name])` 과 같은 식으로 목을 만들 대상을 지정하는 것입니다.

```jsx
jest.mock("./complicated-logger");
jest.mock("./configuration-service");

const { stringMatching } = expect;
const { verifyPassword } = require("./password-verifier");
const mockLoggerModule = require("./complicated-logger");
const stubConfigModule = require("./configuration-service");

describe("password verifier", () => {
  afterEach(jest.resetAllMocks);

  test(`with info log level and no rules, 
          it calls the logger with PASSED`, () => {
    stubConfigModule.getLogLevel.mockReturnValue("info");

    verifyPassword("anything", []);

    expect(mockLoggerModule.info).toHaveBeenCalledWith(stringMatching(/PASS/));
  });

  test(`with debug log level and no rules, 
          it calls the logger with PASSED`, () => {
    stubConfigModule.getLogLevel.mockReturnValue("debug");

    verifyPassword("anything", []);

    expect(mockLoggerModule.debug).toHaveBeenCalledWith(stringMatching(/PASS/));
  });
});
```

가장 윗줄에서 모듈을 가짜로 만든 후, 모듈을 불러옵니다. 모듈을 불러와 테스트의 준비단계에서 stub의 반환값을 조정해둡니다. 이후 expect에서는 mock 의 모의함수가 호출되었는지 검증합니다.

참고로 자바스크립트의 ‘호이스팅’ 특성 때문에 모듈을 가짜로 만드는 코드(jest.mock)는 파일 가장 위쪽에 위치해야 합니다.

### 직접 의존성의 추상화 고민

`jest.mock` 의 단점은 제어권이 있는 코드까지 모두 가짜로 만들어 버린다는 것입니다. 이렇게 하면 실제 의존성을 더 간단한 내부API로 추상화하여 숨기는 방식의 이점을 놓칠 수 있습니다.

직접 의존성이 왜 문제가 될 수 있을까요? 이러한 API를 직접 사용하면 추상화된 API가 아닌 모듈 API를 테스트에서 직접 가짜로 만들어야 합니다. 이렇게 하면 모듈의 원래 API설계가 테스트 구현에 밀접하게 결합되어 API가 변경될 때마다 수많은 테스트를 함께 변경해야 합니다.

## 3. 함수형 스타일의 동적 목과 스텁

모듈 의존성을 다루었으니 이제 간단한 함수를 가짜로 만드는 방법을 살펴 보겠습니다. `jest.fn` 은 이러한 반복 작업을 없애기에 가장 쉬운 방법입니다.

```jsx
const { makeVerifier } = require("./00-password-verifier");

test("given logger and passing scenario", () => {
  const mockLog = { info: jest.fn() };
  const verify = makeVerifier([], mockLog);

  verify("any input");

  expect(mockLog.info).toHaveBeenCalledWith(expect.stringMatching(/PASS/));
});
```

이제 `toHaveBeenCalledWith` 함수를 사용하여 모의 함수가 호출되었는지 확인할 수 있습니다. `expect.stringMatching` 함수는 Jest에서 매처(Matcher)라고 부르는 것의 한 예시입니다. 매처는 함수에 전달되는 매개변수 값을 검증하는 유틸리티 함수입니다.

## 4. 객체 지향 스타일의 동적 목과 스텁

### 느슨한 타입의 프레임워크 사용

```jsx
export interface IComplicatedLogger {
  info(text: string, method: string);
  debug(text: string, method: string);
  warn(text: string, method: string);
  error(text: string, method: string);
}
```

이 인터페이스의 스텁이나 목을 직접 작성하려면 시간이 많이 필요하게 됩니다. 이에 대한 스텁을 직접 만드려면 코드가 굉장히 길고 복잡해질 것입니다.

```jsx
describe("working with long interfaces", () => {
  describe("password verifier", () => {
    test("verify, w logger & passing, calls logger with PASS", () => {
      const mockLog: IComplicatedLogger = {
        info: jest.fn(),
        warn: jest.fn(),
        debug: jest.fn(),
        error: jest.fn(),
      };

      const verifier = new PasswordVerifier([], mockLog);
      verifier.verify("anything");

      expect(mockLog.info).toHaveBeenCalledWith(
        expect.stringMatching(/PASSED/),
        expect.stringMatching(/verify/)
      );
    });
  });
});
```

jest를 사용하면 위와 같이 간단하게 작성할 수 있습니다. 이렇게 할 경우 한 가지 주의 사항이 있습니다. 인터페이스가 변경되어 함수가 추가되면 이 모의 객체를 정의하는 코드를 수정하여 함수를 추가해야 합니다.

상황을 복잡하게 만들지 않으려면 이러한 모의 객체는 팩토리 함수와 같은 함수 내부로 옮겨서 객체의 생성 처리를 한곳에서만 하는 것이 좋은 선택일 수 있습니다.

### 정적 타입의 프레임워크 사용

이제 두 번째 유형(정적 타입 격리 프레임워크)에 해당하는 프레임워크인 substitute.js 를 사용해보겠습니다. 위의 예시를 작성하면 아래와 같습니다.

```jsx
describe('working with long interfaces', () => {
  describe('password verifier', () => {
    test('verify, with logger and passing, calls logger with PASS', () => {
      const mockLog = Substitute.for<IComplicatedLogger>();

      const verifier = new PasswordVerifier([], mockLog);
      verifier.verify('anything');

      mockLog.received().info(
        Arg.is((x) => x.includes('PASSED')),
        'verify'
      );
    });
  });
});
```

`Substitute.for` 로 모의 객체를 생성하는 것을 볼 수 있습니다. 객체의 시그니처에 새로운 함수가 추가되더라도 테스트를 거의 변경할 필요가 없다는 이점이 있습니다.

## 5. 동적 스텁 설정

jest는 모듈과 함수 의존성의 반환 값을 조작하는 함수로 `mockReturnValue` 와 `mockReturnValueOnce` 를 제공합니다.

```jsx
test("fake same return values", () => {
  const stubFunc = jest.fn().mockReturnValue("abc");

  expect(stubFunc()).toBe("abc");
  expect(stubFunc()).toBe("abc");
  expect(stubFunc()).toBe("abc");
});

test("fake multiple return values", () => {
  const stubFunc = jest
    .fn()
    .mockReturnValueOnce("a")
    .mockReturnValueOnce("b")
    .mockReturnValueOnce("c");

  expect(stubFunc()).toBe("a");
  expect(stubFunc()).toBe("b");
  expect(stubFunc()).toBe("c");
  expect(stubFunc()).toBe(undefined);
});
```

`mockReturnValue` 는 테스트 동안 항상 동일한 값을 반환하도록 할 수 있고, `mockReturnValueOnce` 는 최초 한 번만 반환하도록 할 수 있습니다.

## 6. 격리 프레임워크의 장점과 함정

이 장에서 배운 격리 프레임워크 내용을 정리하면 다음 장점이 있습니다:

- 손쉬운 가짜 모듈 생성: 격리 프레임워크는 보일러 플레이트 코드를 제거하여 모듈 의존성을 쉽게 처리할 수 있게 도와줄 수 있습니다.
- 값이나 오류를 만들어 내기가 더 쉬워짐 : 모의 객체를 수작업으로 작성하는 것이 훨씬 쉬워집니다.
- 가짜 객체 생성이 더 쉬워짐: 목이나 스텁을 더 쉽게 생성할 수 있습니다.

이렇게 장점이 있지만, 잠재적인 위험 요소도 있습니다.

### 대부분의 경우 모의 객체가 필요하지 않다.

격리 프레임워크의 가장 무시하기 힘든 함정은 무엇이든 쉽게 가짜로 만들 수 있다는 것과 애초에 모의 객체가 필요하다고 생각하게 하는 것입니다.

테스트를 정의하면서 모의 객체나 모의 함수가 호출되었는지 검증하기 전에 모의 객체 없이도 동일한 기능을 검증할 수 있는지 잠시 생각해 보시길 바랍니다. 모의 객체나 스텁을 사용하면 외부 의존성에 영향을 받아 테스트 난이도가 올라갈 수 있습니다.

### 읽기 어려운 테스트 코드

하나의 테스트에 많은 목을 만들거나 검증 단계를 너무 많이 추가하면 테스트 가독성이 떨어져 유지 보수가 어렵고, 무엇을 테스트하고 있는지 이해하기도 힘들 수 있습니다.

### 잘못된 대상 검증

모의 객체를 사용하면 인터페이스의 메서드나 함수가 호출되었는지 확인할 수 있지만, 그렇다고해서 항상 올바른 대상을 테스트하고 있는 것은 아닙니다. 테스트에 입문하는 사람들이 흔하게 저지르는 실수는 실제로 의미 있는 동작을 검증하기보다는 단지 가능하기 때문에 검증을 하는 것입니다.

### 테스트당 하나 이상 목을 사용

테스트에서는 하나의 관심사만 검증하는 것을 좋은 관행으로 여깁니다. 여러 가지를 한 번에 테스트하면 헷갈리기만 하고 유지 보수의 난이도만 올라가기 때문입니다.

하나의 테스트에 목을 두 개 이상 사용하는 것은 동일한 작업 단위의 여러 종료점을 한꺼번에 테스트하는 것과 같습니다.

### 테스트의 과도한 명세화

테스트에 검증 항목이 너무 많으면 아주 작은 프로덕션 코드 변경에도 쉽게 깨질 수 있습니다. 너무 많아도 너무 적어도 안됩니다. 이러한 현상을 균형있게 유지하려면 다음 방법을 고민해 보아야 합니다.

- 목 대신 스텁을 사용하기: 스텁은 어디에서든 여러 번 사용해도 상관없지만, 모의 객체는 그렇지 않습니다.
- 가능한 스텁을 목으로 사용하지 않기: 스텁은 테스트 중인 작업 단위에 가짜 값을 제공하거나 예외를 던지기 위해서만 사용하되, 스텁에서 메서드 호출 여부는 검증하지 않아야 합니다.

## Wrap Up

격리 프레임워크는 테스트를 더 간단하고 효율적으로 만들어줍니다. 동적 목과 스텁을 통해 코드의 의존성을 쉽게 관리할 수 있습니다. 하지만 남용하면 테스트의 가독성과 신뢰성을 해칠 수 있습니다. 따라서 적절한 사용과 함께 테스트의 목적을 명확히 해야 합니다.

### Summary

격리 프레임워크는 동적 목과 스텁을 생성하여 테스트를 단순화합니다. 이 때, 느슨한 타입과 정적 타입의 프레임워크를 선택할 수 있습니다. Jest와 substitute.js를 사용하여 다양한 테스트 시나리오를 구현할 수 있습니다.

모의 객체 사용 시 과도한 명세화와 잘못된 대상 검증을 피해야 합니다. 테스트의 가독성과 유지 보수성을 고려하여 목과 스텁을 적절히 사용해야 합니다. 이를 통해 더 신뢰할 수 있는 테스트 코드를 작성할 수 있습니다.

### Reference

- [단위 테스트의 기술](https://www.gilbut.co.kr/book/view?bookcode=BN004314)
- [The Art of Unit Testing, Third Edition](https://www.manning.com/books/the-art-of-unit-testing-third-edition?a_aid=iserializable&a_bid=8948c3bc)

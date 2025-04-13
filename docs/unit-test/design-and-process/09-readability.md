---
title: 가독성
description: 단위 테스트의 가독성을 높이는 방법과 테스트 이름 짓기, 변수 이름 지정, 검증과 실행 단계 분리, 초기화 및 설정 해제에 대한 모범 사례를 다룹니다.
sidebar_position: 1
tags:
  - unit-test
---

가독성은 코드가 무엇을 하고 어디에서 하는지 읽는 사람이 이해할 수 있도록 해야 합니다. 테스트 코드의 가독성을위해 아래 4가지를 다뤄 보겠습니다.

- 단위 테스트 이름 짓기
- 변수 이름 짓기
- 검증(assert)과 실행(action)단계 분리초기화 및 설정 해제

## 1. 단위 테스트 이름 짓기

이름을 짓는 기준은 테스트를 명확히 설명하는 데 중요한 역할을 합니다. 테스트 이름이나 테스트가 포함된 파일 구조에는 다음 세 가지 중요한 정보가 포함되어야 합니다.

- 작업 단위의 진입점(혹은 현재 테스트 중인 기능 이름)
- 진입점을 테스트하는 상황
- 작업 단위의 종료점이 실행해야 하는 동작

예를 들어 테스트 이름을 ‘진입점 x를 null값으로 호출하면, y를 실행한다’. 형식으로 작성한다는 것입니다. 작업 단위의 종료점에서 무엇을 해야 하거나 반환해야 하는지, 또는 어떻게 동작해야 하는지 알기 쉬운 말로 설명해야 합니다.

위의 세 가지 요소는 테스트를 읽는 사람이 쉽게 볼 수 있는 곳에 있어야 합니다. 이 모든 요소를 하나의 테스트 함수 이름에 포함시킬 수도 있고, 중첩된 `describe()` 블록을 사용해서 나눌 수도 있습니다.

```tsx
test("verifyPassword, with a failing rule, returns error based on rule.reason", () => {
  // ...
});

describe("verifyPassword", () => {
  describe("with a failing rule", () => {
    it("returns error based on the rule.reason", () => {
      // ...
    });
  });
});
```

2장에서 나온 USE 전략이 도움될 것 같습니다. (Unit - Scenario - Expectation)

필수 정보 세 가지를 포함해야 하는 **또 다른 이유**는 테스트를 실패할 때 표시되는 화면때문입니다. CI에서 실패하면 로그에서는 실패한 테스트 이름만 보이고, 주석이나 테스트 코드자체는 볼 수 없습니다. 이름을 명확하고 이해하기 쉽게 지었다면 테스트 코드를 읽거나 디버깅할 필요 없이 로그만 읽고도 실패 원인을 이해할 수 있습니다.

## 2. 매직 넘버와 변수 이름

매직 넘버란 하드코딩된 값, 기록에 남지 않은 값, 명확하게 이해되지 않는 상수나 변수를 의미합니다.

```tsx
describe("password verifier", () => {
  test("on weekends, throws exceptions", () => {
    expect(() => verifyPassword("jhGGu78!", [], 0)).toThrowError(
      "It's the weekend!"
    );
  });
});
```

매직넘버가 쓰여진 예제입니다.

- 0은 여러가지 의미로 해석될 수 있습니다. 코드를 읽는 사람 입장에서는 이 값이 요일을 나타낸다는 것을 이해하려면 시간이 걸립니다.
- 코드를 읽는 사람 입장에서 빈 배열이 규칙이 담긴 배열이라는 것을 이해하기 쉽지 않습니다. 위 코드는 아무 규칙이 없는 경우를 테스트한다는 것입니다.
- `jgGGu78!` 는 비밀번호처럼 보이지만 코드를 읽는 입장에서는 특별한 의미가 있다고 여길 수도 있습니다. 결국 다른 테스트에서도 써야할 것처럼 여겨지고 점점 다른 테스트에도 퍼질 수 있습니다.

위를 수정하면 다음과 같습니다.

```tsx
describe("verifier2 - dummy object", () => {
  test("on weekends, throws exceptions", () => {
    const SUNDAY = 0;
    const NO_RULES = [];
    expect(() => verifyPassword2("anything", NO_RULES, SUNDAY)).toThrowError(
      "It's the weekend!"
    );
  });
});
```

매직넘버를 의미있는 변수로 대체하였고, 비밀번호 값은 직접적인 값인 `anything` 으로 변경하여 “아무거나”라는 의미를 전달함으로써 이 테스트에서 비밀번호는 중요하지 않다는 것을 알려 줄 수 있습니다. 변수 이름과 값은 중요한 것을 설명하는 역할도 하지만, 코드를 읽는 사람이 어떤 부분을 **신경 쓰지 않아도 되는지 알려주는 역할**도 합니다.

## 3. 검증과 실행 단계 분리

가독성을 높이려면 검증 단계와 실행 단계를 한 문장에 넣지 말아야 합니다.

```tsx
expect(verifier.verify("any value")[0]).toContain("fake reason");

const result = verifier.verify("any value");
expect(result[0]).toContain("fake reason");
```

첫 번째 라인을 보면 실행 부분과 검증 부분이 함께 쓰여 있어 테스트에서 읽고 이해하기가 어렵습니다.

2장 AAA

## 4. 초기화 및 설정 해제

단위 테스트에서 초기화와 해제 함수는 남용되기 쉽습니다. 이는 테스트에 필요한 초기 설정이나 테스트가 끝난 후 목을 다시 초기화하는 등 해제 작업이 가독성을 떨어트립니다.

```tsx
describe("password verifier", () => {
  let mockLog;
  beforeEach(() => {
    mockLog = Substitute.for<IComplicatedLogger>();
  });

  test("verify, with logger & passing, calls logger with PASS", () => {
    const verifier = new PasswordVerifier([], mockLog);
    verifier.verify("anything");

    mockLog.received().info(
      Arg.is((x) => x.includes("PASSED")),
      "verify"
    );
  });
});
```

초기화 함수나 `beforeEach()` 함수를 사용하여 목이나 스텁을 설정하면 테스트 내에서는 해당 객체를 어디서 만들었는지 찾기 어렵습니다. 이 상황은 테스트가 많아질수록 코드를 읽는 사람은 이게 어디에서 초기화되었는지, 어떻게 동작하는지 찾아보기 힘들어집니다.

목은 테스트 내에서 직접 초기화하고 모든 기댓값을 설정하는 것이 훨씬 더 가독성이 좋습니다. 유지 보수성까지 신경쓴다면, 팩토리 함수를 만들어 목을 생성하고 이를 여러 테스트에서 사용할 수 있도록 합니다.

```tsx
describe("password verifier", () => {
  test("verify, with logger & passing, calls logger with PASS", () => {
    const mockLog = makeMockLogger();
    const verifier = new PasswordVerifier([], mockLog);
    verifier.verify("anything");

    mockLog.received().info(
      Arg.is((x) => x.includes("PASSED")),
      "verify"
    );
  });
});
```

## Wrap Up

가독성 높은 테스트 코드는 유지보수와 디버깅을 더 쉽게 만들어 줍니다. 테스트 이름, 변수 이름, 검증과 실행 단계의 분리, 그리고 초기화 로직은 모두 테스트 코드의 가독성에 큰 영향을 미칩니다. 이러한 가독성 향상 기법을 적용하면 다른 개발자들도 코드를 이해하고 디버깅하는 데 소요되는 시간을 크게 줄일 수 있습니다.

### Summary

가독성 높은 테스트는 테스트의 목적과 동작을 분명하게 전달해야 합니다. 테스트 이름은 작업 단위의 진입점, 테스트 상황, 예상되는 결과를 명확히 포함해야 합니다. 매직 넘버 대신 의미 있는 변수명을 사용하여 코드의 의도를 명확히 해야 합니다. 검증 단계와 실행 단계를 분리하면 테스트 로직을 더 쉽게 이해할 수 있습니다. 초기화와 설정 해제는 가능하면 테스트 내에서 직접 처리하거나 명확한 팩토리 함수를 사용하는 것이 좋습니다. AAA(Arrange-Act-Assert) 패턴을 따르면 테스트 구조를 일관되게 유지할 수 있습니다. 가독성 높은 테스트는 실패했을 때 원인을 신속하게 파악할 수 있게 해줍니다.

### Reference

- [단위 테스트의 기술](https://www.gilbut.co.kr/book/view?bookcode=BN004314)
- [The Art of Unit Testing, Third Edition](https://www.manning.com/books/the-art-of-unit-testing-third-edition?a_aid=iserializable&a_bid=8948c3bc)

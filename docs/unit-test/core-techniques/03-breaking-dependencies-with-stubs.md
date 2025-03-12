---
title: 의존성 분리와 스텁
description: TBD
sidebar_position: 1
tags:
  - unit-test
---

## 의존성 유형

작업 단위에서 사용할 수 있는 의존성에는 주요한 두 가지 유형이 존재합니다.

- 외부로 나가는 의존성:
  - 작업 단위의 종료점을 나타내는 의존성.
  - logger 호출, DB write, 이메일 발송 등.
  - 작업 단위에서 외부로 흘러가는 일종의 `fire-and-forget` 시나리오를 의미.
  - 각 작업은 종료점을 나타내거나, 작업 단위 내 특정 논리 흐름의 끝을 나타낸다.
- 내부로 들어오는 의존성:
  - 종료점을 나타내지 않는 의존성.
  - 테스트에 필요한 특수한 데이터나 동작을 작업 단위에 제공하는 역할.
  - DB 쿼리 결과, 파일 시스템 접근, 네트워크 응답 결과 등이 여기에 해당.
  - 작업 단위로 들어오는 수동적인 데이터 조각을 나타낸다.

어떤 의존성은 외부로 나가는 의존성이기도 하면서 동시에 내부로 들어오는 의존성이기도 합니다. 외부 api 가 응답 결과로 성공/실패 응답을 받아 서드 파티를 호출하는 경우가 여기에 해당됩니다.
<xUnit 테스트 패턴> 에서는 테스트에서 실제 의존성을 대체하거나 모방하는 데 다양한 패턴을 정의합니다.

| 카테고리   | 패턴          | 목적                                                                                          | 사용법                                                                              |
| ---------- | ------------- | --------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------- |
|            | 테스트 더블   | 스텁과 목을 포함하는 일반적인 용어                                                            | 이 책의 필자는 '페이크' 라는 용어를 사용함                                          |
| 스텁(stub) | 더미 객체     | 테스트에서 사용될 값을 지정하는 데 사용                                                       | 진입점의 매개변수로 전달되거나 `arrange` 단계에서 사용됨                            |
|            | 테스트 스텁   | 다른 소프트웨어 구성 요소의 간접 입력에 의존할 때 독립적으로 로직을 검증하는 데에 사용        | 의존성으로 주입하고 SUT 에 특정 값이나 동작을 반환                                  |
| 목(mock)   | 테스트 스파이 | 다른 소프트웨어 구성 요소에 간접 출력을 보낼 때 독립적으로 로직을 검증하는 데 사용            | 실제 객체의 메서드를 오버라이드하고, 오버라이드한 함수가 예상대로 호출되었는지 확인 |
|            | 모의 객체     | 다른 소프트웨어 구성 요소에 대한 간접 출력에 의존하는 경우 독립적으로 로직을 검증하는 데 사용 | 가짜 객체를 SUT 의존성으로 주입하고 가짜 객체가 예상대로 호출되었는지 확인          |

#### 스텁은 내부로 들어오는 의존성(간접 입력)을 끊어 준다

스텁은 가짜 모듈이나 객체 및 가짜 동작이나 데이터를 코드 **내부로 보내는** 가짜 함수를 의미합니다. 이를 통해 테스트 대상 코드가 외부 시스템이나 데이터에 의존하지 않고도 동작할 수 있게 합니다. 스텁은 검증하지 않기 때문에 하나의 테스트에서 여러 스텁을 사용할 수 있습니다.

#### 목은 외부로 나가는 의존성(간접 출력 또는 종료점)을 끊어 준다

목은 가짜 모듈이나 객체 및 호출 여부를 검증하는 함수를 의미합니다. 목은 단위 테스트에서 **종료점**을 나타냅니다. 따라서 하나의 테스트에 목은 하나만 사용하는 것이 일반적입니다.

현업에서는 'mock' 이라는 단어가 스텁과 목을 아우르는 용어로 사용되는데, 이 둘은 큰 차이가 있기 때문에 올바른 용어를 사용해야 합니다.

> [!NOTE] xUnit 테스트 패턴과 이름 규칙
> <xUnit 테스트 패턴> 에서는 단위 테스트의 패턴을 다양하게 정의합니다. 이 책에서는 '페이크' 라는 용어를 'SUT가 의존하는 구성 요소를 훨씬 가벼운 구현으로 대체하는 것' 이라 정의합니다. 본 책의 저자는 이 유형의 테스트 더블을 '스텁'으로 간주하며, '페이크'라는 용어는 실제가 아닌 모든 것을 지칭하는 데 사용합니다.

> [!NOTE] 스텁, 목, 페이크의 이해
>
> ### 스텁
>
> 스텁은 테스트 대상 코드에 미리 정의된 가짜 데이터를 제공합니다. 예를 들어 데이터베이스 상태와 무관하게 검색 기능을 테스트할 수 있는 수단을 제공할 수 있습니다. 이처럼 스텁은 테스트 독립성을 높여 주지만, 호출 여부는 검증하지 않습니다.
>
> ### 목
>
> 목은 외부 시스템과 상호 작용을 시뮬레이션하고, 호출 여부나 호출된 파라미터를 검증하는 데에 사용됩니다. 예를 들어 장바구니 기능을 구현할 때 실제로 데이터베이스에 변경이 가해지지 않더라도 장바구니에 항목을 추가하는 함수가 제대로 호출되었는지, 어떤 파라미터로 호출되었는지 등을 검증하는 데에 목을 사용합니다. 목은 하나의 테스트에서 하나만 사용하는 것이 좋습니다.
>
> ### 페이크
>
> 페이크는 실제 구현을 대체하는 가벼운 버전의 구성 요소입니다. 예를 들어 실제 운영 데이터베이스 대신 인메모리 데이터베이스를 사용하여 테스트를 수행하는 경우를 들 수 있습니다.

## 스텁을 사용하는 이유

아래와 같은 코드를 생각해볼 수 있습니다.

```js
const moment = require("moment");
const SUNDAY = 0;
const SATURDAY = 6;

const verifyPassword = (input, rules) => {
  const dayOfWeek = moment().day();
  if ([SATURDAY, SUNDAY].includes(dayOfWeek)) {
    throw Error("It's the weekend!");
  }
  // more code goes here...
  // return list of errors found..
  return [];
};
```

이 모듈은 날짜/시간을 다루는 라이브러리 `moment.js` 에 직접적으로 의존합니다. 이러한 경우, 날짜나 시간을 직접 통제할 수 없어 아래와 같이 주말에만 실행되는 테스트가 발생할 수도 있습니다.

```js
describe("verifier", () => {
  const TODAY = moment().day();

  // test is always executed, but might not do anything
  test("on weekends, throws exceptions", () => {
    if ([SATURDAY, SUNDAY].includes(TODAY)) {
      expect(() => verifyPassword("anything", [])).toThrowError(
        "It's the weekend!"
      );
    }
  });

  // test is not even executed on week days
  if ([SATURDAY, SUNDAY].includes(TODAY)) {
    test("on a weekend, throws an error", () => {
      expect(() => verifyPassword("anything", [])).toThrow("It's the weekend!");
    });
  }
});
```

좋은 테스트의 기준 중 하나인 일관성 측면에서, 테스트는 언제 실행하든 이전 실행과 같은 결과를 보장해야 합니다.

## 스텁을 사용하는 일반적인 설계 방식

작업 단위에 스텁을 주입하는 방식은 아래와 같은 '매개변수화' 방식이 존재합니다:

- 함수를 사용한 방식:
  - 함수를 매개변수로 사용.
  - 부분 적용(커링).
  - 팩토리 함수.
  - 생성자 함수.
- 모듈을 이용한 방식:
  - 모듈 주입.
- 객체 지향을 이용한 방식:
  - 클래스 생성자 방식.
  - 객체를 매개변수로 사용(덕 타이핑).
  - 공통 인터페이스를 매개변수로 사용.

### 스텁으로 만든 시간을 매개변수로 주입

시간을 제어해야 하는 두 가지 이유가 존재합니다:

- 테스트의 변동성을 없애기 위해.
- 시간과 관련된 시나리오를 쉽게 테스트하기 위해. 아래와 같이 작성할 수 있습니다.

```js
const verifyPassword2 = (input, rules, currentDay) => {
  if ([SATURDAY, SUNDAY].includes(currentDay)) {
    throw Error("It's the weekend!");
  }
  // more code goes here...
  // return list of errors found..
  return [];
};
```

```js
describe("verifier2 - dummy object", () => {
  test("on weekends, throws exceptions", () => {
    expect(() => verifyPassword2("anything", [], SUNDAY)).toThrowError(
      "It's the weekend!"
    );
  });
});
```

이렇게 주입하는 값을 '더미'라고 부르는데, 이 책에서는 '스텁' 이라고 부릅니다.
이러한 접근 방식은 의존성 역전(dependency inversion)의 한 형태입니다.
이렇게 함으로서 테스트 일관성을 확보한 것 외에도 아래와 같은 장점이 존재합니다:

- 원하는 날짜를 쉽게 설정 가능.
- 더 이상 날짜/시간 라이브러리를 직접 다루지 않아 라이브러리 변경이 용이
  <xUnit 테스트 패턴> 정의에 따르면 `currentDay` 파라미터는 '더미' 값에 해당합니다. 함수에 전달되는 특정 입력 값이나 동작을 모방하는 데에 `currentDay`를 사용하고 있으므로 스텁이라고도 볼 수 있습니다. 스텁은 꼭 복잡할 필요는 없습니다.

## 함수를 이용한 주입 방법

### 함수 주입

데이터를 의존성으로 직접 받는 대신 데이터를 반환하는 함수를 매개변수로 받을 수 있습니다.

```js
const verifyPassword3 = (input, rules, getDayFn) => {
  const dayOfWeek = getDayFn();
  if ([SATURDAY, SUNDAY].includes(dayOfWeek)) {
    throw Error("It's the weekend!");
  }
  // more code goes here...
  // return list of errors found..
  return [];
};
```

```js
describe("verifier3 - dummy function", () => {
  test("on weekends, throws exceptions", () => {
    const alwaysSunday = () => SUNDAY;
    expect(() => verifyPassword3("anything", [], alwaysSunday)).toThrowError(
      "It's the weekend!"
    );
  });
  test("on week days, works fine", () => {
    const alwaysMonday = () => MONDAY;

    const result = verifyPassword3("anything", [], alwaysMonday);

    expect(result.length).toBe(0);
  });
});
```

함수를 매개변수로 전달하는 방법은 특정 상황에서 예외를 만들어 내거나 테스트 내에서 특정한 동작을 하도록 만들 수 있어 유용합니다.

### 부분 적용을 이용한 의존성 주입

```js
const SUNDAY = 0;
const MONDAY = 1;
const TUESDAY = 2;
const WEDNESDAY = 3;
const THURSDAY = 4;
const FRIDAY = 5;
const SATURDAY = 6;

const makeVerifier = (rules, dayOfWeekFn) => {
  return function (input) {
    if ([SATURDAY, SUNDAY].includes(dayOfWeekFn())) {
      throw new Error("It's the weekend!");
    }
    // use the rules, luke
    // more code goes here..
  };
};
```

```js
describe("verifier", () => {
  test("factory method: on weekends, throws exceptions", () => {
    const alwaysSunday = () => SUNDAY;
    const verifyPassword = makeVerifier([], alwaysSunday);

    expect(() => verifyPassword("anything")).toThrow("It's the weekend!");
  });
});
```

위 예제에서는 팩토리 함수를 테스트의 `arrange` 단계에서 사용하고, 반환된 함수를 `act` 단계에서 호출합니다. `arrange` 단계에서 `rules` 와 `getDayFn` 을 파라미터로 전달하여 팩토리 함수가 반환하는 새로운 함수가 이들을 참조할 수 있도록 합니다.

## 모듈을 이용한 주입 방법

테스트 코드에서 의존성을 직접 가져오는 경우는 의존성 주입을 아래와 같이 처리할 수 있습니다.

```js
const originalDependencies = {
  moment: require("moment"),
};

let dependencies = { ...originalDependencies };

const inject = (fakes) => {
  Object.assign(dependencies, fakes);
  return function reset() {
    dependencies = { ...originalDependencies };
  };
};

const SUNDAY = 0;
const SATURDAY = 6;

const verifyPassword = (input, rules) => {
  const dayOfWeek = dependencies.moment().day();
  if ([SATURDAY, SUNDAY].includes(dayOfWeek)) {
    throw Error("It's the weekend!");
  }
  // more code goes here...
  // return list of errors found..
  return [];
};
```

```js
const injectDate = (newDay) => {
  const reset = inject({
    moment: function () {
      // we're faking the moment.js module's API here.
      return {
        day: () => newDay,
      };
    },
  });
  return reset;
};

describe("verifyPassword", () => {
  describe("when its the weekend", () => {
    it("throws an error", () => {
      const reset = injectDate(SATURDAY);

      expect(() => verifyPassword("any input")).toThrowError(
        "It's the weekend!"
      );

      reset();
    });
  });
});
```

`moment.js` 모듈을 불러와 사용하던 코드를 `originalDependencies` 객체로 저장합니다. 테스트 코드에서는 `injectDate()` 함수를 이용해 `moment.js` 모듈을 가짜 객체로 만들어 `moment.js` 의 의존성 문제를 해결합니다.
의존성 문제를 확실히 해결하고 사용이 비교적 쉽다는 장점도 존재하지만, 테스트를 우리가 가짜로 만든 의존성의 api에 매우 강하게 묶이게 하는 단점도 존재합니다. 예를 들어, logger 모듈에 대한 가짜 의존성을 작성했을 때 logger 모듈의 api 가 수정된다면, 파일을 수백 개 수정해야 할 수도 있습니다. 이러한 상황을 막을 수 있는 방법으로 `헥사고날 아키텍처` 를 사용하는 방법이 존재합니다.

> [!NOTE] 포트와 어댑터 아키텍처에 대한 이해
> 포트는 시스템의 내부와 외부를 연결하는 인터페이스를 의미합니다. 예를 들어, 음악 재생기 앱에서 음악을 재생하는 포트를 정의할 수 있습니다.
> 어댑터는 포트를 통해 들어오는 요청을 처리하는 구체적인 구현체입니다. 예를 들어, 로컬 파일 시스템에서 음악 파일을 재생하는 어댑터를 구현할 수 있습니다.

## 생성자 함수를 사용하여 객체 지향적으로 전환

팩토리 함수와 동일한 결과를 얻을 수 있는 보다 객체지향적인 방식입니다.

```js
const SUNDAY = 0;
const SATURDAY = 6;

const Verifier = function (rules, dayOfWeekFn) {
  this.verify = function (input) {
    if ([SATURDAY, SUNDAY].includes(dayOfWeekFn())) {
      throw new Error("It's the weekend!");
    }
    //more code goes here..
  };
};
```

```js
test("constructor function: on weekends, throws exception", () => {
  const alwaysSunday = () => SUNDAY;
  const verifier = new Verifier([], alwaysSunday);
  expect(() => verifier.verify("anything")).toThrow("It's the weekend!");
});
```

## 객체 지향적으로 의존성을 주입하는 방법

### 생성자 주입

클래스의 생성자를 이용해 의존성을 주입하는 설계를 의미합니다.

```js
const SUNDAY = 0;
const MONDAY = 1;
const SATURDAY = 6;

class PasswordVerifier {
  constructor(rules, dayOfWeekFn) {
    this.rules = rules;
    this.dayOfWeek = dayOfWeekFn;
  }
  verify(input) {
    if ([SATURDAY, SUNDAY].includes(this.dayOfWeek())) {
      throw new Error("It's the weekend!");
    }
    const errors = [];
    //more code goes here..
    return errors;
  }
}
```

```js
describe("verifier", () => {
  test("class constructor: on weekends, throws exception", () => {
    const alwaysSunday = () => SUNDAY;
    const verifier = new PasswordVerifier([], alwaysSunday);
    expect(() => verifier.verify("anything")).toThrow("It's the weekend!");
  });
});
```

생성자를 사용하여 클래스를 만드는 과정을 팩토리 함수로 분리하면 좋습니다. 이렇게 하면 생성자 함수의 로직이 변경되어 다수의 테스트가 한꺼번에 깨지더라도 생성자 함수만 수정하면 테스트를 다시 복구할 수 있기 때문입니다.

```js
describe("refactored with constructor", () => {
  const makeVerifier = (rules, dayFn) => {
    return new PasswordVerifier(rules, dayFn);
  };

  test("class constructor: on weekends, throws exceptions", () => {
    const alwaysSunday = () => SUNDAY;
    const verifier = makeVerifier([], alwaysSunday);
    expect(() => verifier.verify("anything")).toThrow("It's the weekend!");
  });

  test("class constructor: on weekdays, with no rules, passes", () => {
    const alwaysMonday = () => MONDAY;
    const verifier = makeVerifier([], alwaysMonday);
    const result = verifier.verify("anything");
    expect(result.length).toBe(0);
  });
});
```

위 테스트 코드의 팩토리 함수는 테스트 코드 내부에 존재하며, 테스트 코드 내에 추상화 계층을 추가합니다. 이 방법으로 함수나 객체를 생성하고 구성하는 방식을 한 곳으로 모아둘 수 있게 해 줍니다.

### 함수 대신 객체 주입

여기서 매개변수로 함수 대신 객체를 받도록 리팩토링 할 수 있습니다.

```js
const SUNDAY = 0;
const MONDAY = 1;
const SATURDAY = 6;

const RealTimeProvider = () => {
  this.getDay = () => moment().day();
};

class PasswordVerifier {
  constructor(rules, timeProvider) {
    this.rules = rules;
    this.timeProvider = timeProvider;
  }

  verify(input) {
    if ([SATURDAY, SUNDAY].includes(this.timeProvider.getDay())) {
      throw new Error("It's the weekend!");
    }
    const errors = [];
    // more code goes here..
    return errors;
  }
}

const passwordVerifierFactory = (rules) => {
  return new PasswordVerifier(rules, new RealTimeProvider());
};
```

```js
function FakeTimeProvider(fakeDay) {
  this.getDay = function () {
    return fakeDay;
  };
}

describe("verifier", () => {
  test("class constructor: on weekends, throws exception", () => {
    const verifier = new PasswordVerifier([], new FakeTimeProvider(SUNDAY));
    expect(() => verifier.verify("anything")).toThrow("It's the weekend!");
  });
});
```

`RealtimeProvider` 가 `PasswordVerifier` 클래스의 파라미터로 전달되어 의존성으로서 주입됩니다. 이때 `RealTimeProvider` 함수는 `moment.js` 모듈에 의존성을 가진 객체를 반환해 `moment.js` 모듈을 이용합니다.
자바스크립트는 `덕 타이핑`을 지원하기 때문에, `RealTimeProvider` 와 `FakeTimeProvider` 가 반환하는 가짜 객체가 동일한 구조를 가진다면 이 둘은 호환됩니다.

### 공통 인터페이스 추출

```ts
export interface TimeProviderInterface {
  getDay(): number;
}

export class RealTimeProvider implements TimeProviderInterface {
  getDay(): number {
    return moment().day();
  }
}

export const SUNDAY = 0,
  SATURDAY = 6;

export class PasswordVerifier {
  private _timeProvider: TimeProviderInterface;

  constructor(rules: any[], timeProvider: TimeProviderInterface) {
    this._timeProvider = timeProvider;
  }

  verify(input: string): string[] {
    const isWeekened =
      [SUNDAY, SATURDAY].filter((x) => x === this._timeProvider.getDay())
        .length > 0;
    if (isWeekened) {
      throw new Error("It's the weekend!");
    }
    return [];
  }
}
```

`TimeProviderInterface` 를 선언해 `덕 타이핑`의 오리가 어떻게 생겼는지를 정의할 수 있습니다.

```ts
class FakeTimeProvider implements TimeProviderInterface {
  fakeDay: number;
  getDay(): number {
    return this.fakeDay;
  }
}

describe("password verifier with interfaces", () => {
  test("on weekends, throws exceptions", () => {
    const stubTimeProvider = new FakeTimeProvider();
    stubTimeProvider.fakeDay = SUNDAY;
    const verifier = new PasswordVerifier([], stubTimeProvider);

    expect(() => verifier.verify("anything")).toThrow("It's the weekend!");
  });
});
```

## Wrap Up

- 의존성은 외부로 나가는 의존성과 내부로 들어오는 의존성으로 구분되며, 외부로 나가는 의존성은 종료점을 나타내고 내부로 들어오는 의존성은 테스트를 위한 데이터를 제공합니다.
- 스텁은 내부로 들어오는 의존성을 끊어 테스트 독립성을 높이며, 목은 외부로 나가는 의존성을 끊어 호출 여부를 검증하는 데 사용됩니다.
- 스텁을 활용하면 테스트 결과가 실행 환경에 따라 변하지 않도록 보장할 수 있으며, 시간과 같은 변수를 제어할 수 있습니다.
- 의존성 주입 방식으로는 함수, 모듈, 객체 지향적인 방법이 있으며, 매개변수 주입, 팩토리 함수, 생성자 주입 등이 포함됩니다.
- 모듈 기반 의존성 주입은 강한 결합을 유발할 수 있어 헥사고날 아키텍처와 같은 패턴을 활용해 결합도를 낮출 필요가 있습니다.
- 객체 지향적인 접근에서는 생성자 주입과 공통 인터페이스를 활용하여 유연성을 높이고, 인터페이스를 사용하면 덕 타이핑을 통한 가짜 객체 주입이 가능합니다.
- 의존성을 적절히 관리하면 테스트의 일관성을 유지하면서 유지보수성을 높일 수 있으며, 실제 구현과 독립적인 테스트 환경을 구축할 수 있습니다.

### Summary

의존성은 외부로 나가는 것과 내부로 들어오는 것으로 나뉘며, 스텁은 내부 의존성을 끊어 테스트 독립성을 높이고, 목은 외부 의존성을 끊어 호출 여부를 검증하는 데 사용됩니다.
다양한 의존성 주입 방법을 활용하면 테스트의 일관성을 유지하고 유지보수성을 높일 수 있습니다.

### Reference

- [단위 테스트의 기술](https://www.gilbut.co.kr/book/view?bookcode=BN004314)
- [단위 테스트의 기술 예제 코드](https://github.com/gilbutITbook/080410)

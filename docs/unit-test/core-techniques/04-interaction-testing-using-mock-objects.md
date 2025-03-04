---
title: 모의 객체를 사용한 상호 작용 테스트
description: TBD
sidebar_position: 2
tags:
  - unit-test
---

# 4장 모의 객체를 사용한 상호 작용 테스트

작업 단위가 가질 수 있는 세 번째 종료점인 서드 파티 함수나 모듈, 객체를 호출하여 테스트하는 방법을 알아봅니다. "목"을 활용하여 작업 단위가 서드 파티 함수와 올바르게 상호 작용하는지 테스트할 수 있습니다.

## 1. 상호 작용 테스트, 목, 스텁

상호 작용 테스트는 작업 단위가 제어할 수 없는 의존성 영역과 어떻게 상호작용하고 메시지를 보내는지(함수를 호출하는지) 확인하는 방법입니다. 모의 함수나 모의 객체를 활용하여 의존성을 제대로 호출했는지 검증할 수 있습니다.

목과 스텁의 차이는 "정보 흐름"에 있습니다.

### 목 
- 가짜로 만든 모듈이나 객체 및 함수입니다.
- 외부로 나가는 의존성과 연결 고리를 끊는 데 사용합니다.
- 단위 테스트에서 종료점을 나타냅니다.
- 어떤 대상을 흉내내서 만들었기 때문에 호출되었는지 확인하는 것이 중요합니다.
- 하나의 테스트에 목은 한 개만 사용하는 것이 일반적입니다.

### 스텁
- 내부로 들어오는 의존성과 연결 고리를 끊는 데 사용합니다.
- 코드에 가짜 동작이나 데이터를 제공하는 가짜 모듈, 객체, 함수를 의미합니다.
- 작업 단위로 들어오는 경유지를 나타내며, 종료점을 나타내지는 않습니다.
- 최종 결과를 달성하는 과정에서 상호 작용일 뿐이므로 종료점으로 취급하지 않습니다.

## 2. 로거 함수에 의존

`verifyPassword`는 2개의 종료점을 보유하고 있습니다.
하나는 값을 반환하고, 하나는 `log.info` 함수를 호출합니다.

```js
// 기존의 의존성 주입 방식으로는 테스트할 수 없다.
const _ = require('lodash');
const log = require('./complicated-logger');

const verifyPassword = (input, rules) => {
  const failed = rules
    .map((rule) => rule(input))
    .filter((result) => result === false);

  console.log(failed);
  if (failed.length === 0) {
    // 이 줄은 전통적인 주입 기법으로는 테스트할 수 없다.
    log.info('PASSED');
    return true;
  }
  // 이 줄은 전통적인 주입 기법으로는 테스트할 수 없다.
  log.info('FAIL');
  return false;
};

```

모듈 내부에서 외부 모듈을 호출하고 있기 때문에 기존 의존성 주입 방식으로는 해결할 수 없습니다.
따라서, 코드를 추상화(불필요한 세부 구현을 숨기고, 핵심적인 개념만 드러냄)하는 방식으로 해결할 수 있습니다.

의존성을 추상화하는 일반적인 방법은 다음과 같습니다.
- 표준 ➔ 매개변수 추가
- 함수형 ➔ 커링 사용, 고차 함수로 변환
- 모듈형 ➔ 모듈 의존성 추상화
- 객체 지향형 ➔ 타입이 없는 객체 주입, 인터페이스 주입

## 3. 기본 스타일 : 매개변수를 주입하는 방식으로 리팩터링

가장 간단하고 확실한 방법은 함수에 매개변수를 추가하는 것입니다.

```js
const verifyPassword2 = (input, rules, logger) => {
  const failed = rules
    .map((rule) => rule(input))
    .filter((result) => result === false);

  if (failed.length === 0) {
    logger.info('PASSED');
    return true;
  }
  logger.info('FAIL');
  return false;
};

describe('password verifier', () => {
  describe('given logger, and passing scenario', () => {
    it('calls the logger with PASSED', () => {
      let written = '';
      const mockLog = { info: (text) => (written = text) };

      verifyPassword2('anything', [], mockLog);

      expect(written).toMatch(/PASSED/);
    });
  });
});
```

변수 이름을 `mockXXX` 로 지어 테스트에 모의 함수나 객체가 있다는 것을 명시적으로 작성합니다.
가독성이 좋아지고 예측 가능한 테스트를 작성할 수 있습니다.

매개변수 추가 방식으로 얻을 수 있는 이점은,
- 테스트 함수 코드에서 외부 모듈을 불러올 필요가 사라집니다.
- 우리가 원하는 로거 함수를 어떤 방식으로든 만들어 주입할 수 있습니다.

## 4. 목과 스텁을 구분하는 것의 중요성

목과 스텁의 차이를 명확하게 짚고 넘어가지 않으면, 
가독성과 유지 보수성이 떨어지는 테스트를 작성할 확률이 높습니다.
특히, 저자는 목과 스텁을 **구분할 수 있는 이름 규칙**이 특히 중요하다고 이야기합니다.

#### 목
- 작업 단위의 요구사항
- 예를 들어, '로거를 호출한다', '이메일을 보낸다' 등
#### 스텁
- 들어오는 정보나 동작
- 예를 들어, '데이터베이스 쿼리가 false를 반환한다', '특정 설정이 오류를 일으킨다' 등

두 개념을 구분하면 다음 장점이 있습니다.
- 가독성 : 이름을 잘 지으면 테스트 코드를 읽지 않고도 테스트 이름만 보고 내부 동작을 유추할 수 있습니다.
- 유지 보수성 : 스텁과 목을 구분하지 않으면 스텁을 검증하는 케이스가 발생할 수 있습니다.
- 신뢰성 : 하나의 테스트에 여러 목(요구 사항)이 있을 때 첫 번째 목을 검증하는 단계에서 실패하면, 실패한 검증 이후의 나머지 작업은 수행하지 않습니다. 이는 하나가 실패하면 다른 목은 검증할 수 없어 결과를 알 수 없음을 의미합니다.

## 5. 모듈 스타일의 목

아래 코드는 모듈을 코드에 직접 import 하고 있습니다.

```js
const { info, debug } = require('./complicated-logger');
const { getLogLevel } = require('./configuration-service');

const log = (text) => {
  if (getLogLevel() === 'info') {
    info(text);
  }
  if (getLogLevel() === 'debug') {
    debug(text);
  }
};

const verifyPassword = (input, rules) => {
  const failed = rules
    .map((rule) => rule(input))
    .filter((result) => result === false);

  if (failed.length === 0) {
    log('PASSED');
    return true;
  }
  log('FAIL');
  return false;
};

module.exports = {
  verifyPassword,
};
```

모듈 의존성을 별도의 객체로 분리하여 원하는 의존성을 외부에서 주입할 수 있도록 만듭니다.

```js
const originalDependencies = {
  log: require('./complicated-logger'),
};

let dependencies = { ...originalDependencies };

const resetDependencies = () => {
  dependencies = { ...originalDependencies };
};

const injectDependencies = (fakes) => {
  Object.assign(dependencies, fakes);
};

const verifyPassword = (input, rules) => {
  const failed = rules
    .map((rule) => rule(input))
    .filter((result) => result === false);

  if (failed.length === 0) {
    dependencies.log.info('PASSED');
    return true;
  }
  dependencies.log.info('FAIL');
  return false;
};

module.exports = {
  verifyPassword,
  injectDependencies,
  resetDependencies,
};
```

## 6. 함수형 스타일에서 목

#### 커링 스타일 사용 
커링을 이용하면 코드의 반복되는 부분을 줄일 수 있습니다.
"이 함수가 실제로 어떻게 사용되고 있는지", "의존성이 무엇인지" 알 수 있습니다.

```js
const _ = require('lodash');

const verifyPassword3 = _.curry((rules, logger, input) => {
  const failed = rules
    .map((rule) => rule(input))
    .filter((result) => result === false);

  if (failed.length === 0) {
    logger.info('PASSED');
    return true;
  }
  logger.info('FAIL');
  return false;
});

describe('password verifier', () => {
  describe('given logger and passing scenario', () => {
    it('calls the logger with PASS', () => {
      let logged = '';
      const mockLog = { info: (text) => (logged = text) };
      const injectedVerify = verifyPassword3([], mockLog);

      // this partially applied function can be passed around
      // to other places in the code
      // without needing to inject the logger
      injectedVerify('anything');

      expect(logged).toMatch(/PASSED/);
    });
  });
});
```

#### 커링 없이 고차 함수 사용

`makeVerifier` 함수를 반환하는 형태인 팩토리 함수로 작성합니다.
규칙과 로거 함수를 매개변수로 받아 이를 클로저 내부에 저장하고, 이러한 설정을 포함한 익명 함수를 반환합니다.

```js
const makeVerifier = (rules, logger) => {
  return (input) => {
    const failed = rules
      .map((rule) => rule(input))
      .filter((result) => result === false);

    if (failed.length === 0) {
      logger.info('PASSED');
      return true;
    }
    logger.info('FAIL');
    return false;
  };
};

describe('higher order factory functions', () => {
  describe('password verifier', () => {
    test('given logger and passing scenario', () => {
      let logged = '';
      const mockLog = { info: (text) => (logged = text) };
      const passVerify = makeVerifier([], mockLog);

      passVerify('any input');

      expect(logged).toMatch(/PASSED/);
    });
  });
});
```


**커링**
함수가 하나의 매개변수만 받아 여러 단계에 걸쳐 호출되는 방식입니다. 
고차함수를 사용하여 새로운 함수를 만듭니다.

```js
const addNumbersInCurrying = (a) => (b) => (c) => {
	return a + b + c;
}
```

**부분 적용**
여러 매개변수를 받는 함수에서 일부 매개변수를 고정하여 새로운 함수를 만드는 방식입니다.
고차함수를 사용하여 새로운 함수를 만듭니다.

```js
const addNumbersInPartialApplication = (a) => (b, c) => {
	return a + b + c;
} 
```

## 7. 객체 지향 스타일의 목

클래스는 생성자를 갖고 있으며 생성자를 통해 클래스의 호출자가 매개변수를 전달하도록 강제할 수 있습니다.
생성자가 아닌 프로퍼티를 사용한다면 의존성이 선택 사항이 되어 객체를 생성한 후 설정할 수 있습니다.
필요한 의존성을 설정하지 않고도 객체가 생성될 수 있어 의존성 주입이 명확하지 않게 됩니다.

```js
class PasswordVerifier {
  _rules;
  _logger;

  constructor(rules, logger) {
    this._rules = rules;
    this._logger = logger;
  }

  verify(input) {
    const failed = this._rules
      .map((rule) => rule(input))
      .filter((result) => result === false);

    if (failed.length === 0) {
      this._logger.info('PASSED');
      return true;
    }
    this._logger.info('FAIL');
    return false;
  }
}

describe('duck typing with function constructor injection', () => {
  describe('password verifier', () => {
    test('logger&passing scenario, calls logger with PASSED', () => {
      let logged = '';
      const mockLog = { info: (text) => (logged = text) };
      const verifier = new PasswordVerifier([], mockLog);
      verifier.verify('any input');

      expect(logged).toMatch(/PASSED/);
    });
  });
});
```

자바나 C# 같은 강타입 언어에서는 가짜 로거 함수를 별도의 클래스로 만듭니다.

```js
class FakeLogger {
  logged = '';

  info(text) {
    this.logged = text;
  }
}

describe('with FakeLogger class  - constructor injection', () => {
  describe('password verifier', () => {
    test('given logger and passing scenario, calls logger with PASSED', () => {
      let logged = '';
      const mockLog = new FakeLogger();
      const verifier = new PasswordVerifier([], mockLog);
      verifier.verify('any input');

      expect(mockLog.logged).toMatch(/PASSED/);
    });
  });
});
```


#### 인터페이스 주입을 이용한 코드 리팩터링

인터페이스는 다형성의 한 형태로, 동일한 인터페이스를 구현하는 객체들이 서로를 대체할 수 있게 합니다.

```js
import { ILogger } from './interfaces/logger';

export class PasswordVerifier {
  private _rules: any[];
  private _logger: ILogger;

  constructor(rules: any[], logger: ILogger) {
    this._rules = rules;
    this._logger = logger;
  }

  verify(input: string): boolean {
    const failed = this._rules
      .map((rule) => rule(input))
      .filter((result) => result === false);

    if (failed.length === 0) {
      this._logger.info('PASSED');
      return true;
    }
    this._logger.info('FAIL');
    return false;
  }
}

class FakeLogger implements ILogger {
  written: string;
  info(text: string) {
    this.written = text;
  }
}

describe('password verifier with interfaces', () => {
  test('verify, with logger, calls logger', () => {
    const mockLog = new FakeLogger();
    const verifier = new PasswordVerifier([], mockLog);

    verifier.verify('anything');

    expect(mockLog.written).toMatch(/PASS/);
  });
});
```


## 8. 복잡한 인터페이스 다루기

테스트 내에서 복잡한 인터페이스를 사용한다면 아래와 같은 문제가 발생할 수 있습니다.
- 인터페이스의 각 메서드를 호출할 때 전달받은 매개변수를 변수에 직접 저장해야 하므로 매개변수 검증하는 것이 번거로워집니다.
- 서드 파티 인터페이스에 의존할 때가 많아 시간이 지나면서 테스트가 더 불안정해집니다.
- 긴 인터페이스는 변경될 가능성이 높아 테스트를 변경해야 할 이유가 많아집니다.

복잡한 인터페이스를 사용해야 한다면, 아래 두 가지 조건을 충족하는 가짜 인터페이스만 사용하시기를 추천드립니다.
- 온전한 제어권이 있는 인터페이스여야 합니다.
- 작업 단위나 컴포넌트의 요구 사항에 맞게 설계된 인터페이스여야 합니다.

인터페이스 분리 원칙
- 인터페이스에 필요한 것보다 더 많은 기능이 포함되어 있으면,
- 필요한 기능만 포함된 더 작은 어댑터 인터페이스를 만들어야 합니다.
- 실제 의존성을 추상화함으로써 복잡한 인터페이스가 변경되더라도 테스트를 변경할 필요가 없습니다.

## 9. 부분 모의 객체

기존 객체와 함수를 감시하는 것이 가능합니다. 이것으로 객체나 함수의 호출 여부나, 몇 번 호출되었는지, 어떤 인수로 호출되었는지 파악할 수 있습니다.

#### 부분 모의 개체를 함수형 방식으로 풀어 보기

RealLogger 클래스를 인스턴스화하고, 기존 메서드 중 하나를 가짜 함수로 대체합니다.

```js
describe('password verifier with interfaces', () => {
  test('verify, with logger, calls logger', () => {
    const testableLog: RealLogger = new RealLogger();
    let logged = '';
    // 부분 모의 객체, 일부가 실제 의존성과 로직을 포함
    testableLog.info = (text) => (logged = text);

    const verifier = new PasswordVerifier([], testableLog);
    verifier.verify('any input');

    expect(logged).toMatch(/PASSED/);
  });
});
```

#### 부분 모의 개체를 객체 지향 방식으로 풀어 보기

클래스의 메서드를 오버라이드하여 해당 메서드가 호출되었는지 검증하는 방식을 사용할 수 있습니다.

```js
class TestableLogger extends RealLogger {
  logged = '';
  info(text) {
    this.logged = text;
  }
  // error() 함수와 debug() 함수는 덮어쓰이지 않았다.
}

describe('partial mock with inheritance', () => {
  test('verify with logger, calls logger', () => {
    const mockLog: TestableLogger = new TestableLogger();

    const verifier = new PasswordVerifier([], mockLog);
    verifier.verify('any input');

    expect(mockLog.logged).toMatch(/PASSED/);
  });
});
```

## Wrap Up

이번 장에서는 모의 객체를 사용한 상호 작용 테스트에 대해 알아보았습니다. 주요 내용을 정리하면 다음과 같습니다:

- 목과 스텁의 차이를 이해하고 적절히 활용하는 것이 중요합니다.
- 의존성 주입은 여러 가지 방식(매개변수, 모듈, 함수형, 객체지향)으로 구현할 수 있습니다.
- 복잡한 인터페이스는 적절히 추상화하여 테스트 가능하게 만들어야 합니다.
- 부분 모의 객체를 활용하여 실제 객체의 일부 동작만 모의할 수 있습니다.

### Summary

모의 객체를 사용한 상호 작용 테스트는 외부 의존성을 가진 코드를 효과적으로 테스트할 수 있게 해줍니다. 목과 스텁을 구분하여 사용하고, 프로젝트에 적합한 의존성 주입 방식을 선택하는 것이 중요합니다. 또한 복잡한 인터페이스는 적절히 추상화하여 테스트 용이성을 높이고, 필요한 경우 부분 모의 객체를 활용하여 유연한 테스트를 구현할 수 있습니다.

### Reference

- [단위 테스트의 기술](https://www.gilbut.co.kr/book/view?bookcode=BN004314)
- [단위 테스트의 기술 예제 코드](https://github.com/gilbutITbook/080410)

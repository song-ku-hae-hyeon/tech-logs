---
title: 첫 번째 단위 테스트
description: TBD
sidebar_position: 2
tags:
  - unit-test
---

# 2장 첫 번째 단위 테스트

## 1. 제스트

제스트는 페이스북에서 만든 오픈 소스 테스트 프레임워크입니다. 리액트 컴포넌트를 테스트하기 위해 만들어졌지만, 현재는 프론트엔드와 백엔드 모두에서 사용됩니다.

테스트 파일은 테스트 대상 파일이나 모듈 옆 또는 별도의 폴더에 위치할 수 있습니다. 본인에게 맞는 방식을 채택하되, 프로젝트 전체에서 일관성을 유지하는 것은 중요합니다.

`jest --watch` 명령어를 사용하면 제스트가 파일 변화를 감지하고 변경된 파일에 대한 테스트를 자동으로 실행합니다. 이는 지속적인 테스트 프로세스에 큰 도움이 됩니다.

## 2. 라이브러리, 검증, 러너, 리포터

제스트는 다음 4가지 역할을 수행합니다:

1) (작성) 테스트를 작성할 때 사용하는 테스트 라이브러리
2) (실행) 테스트 러너 역할
3) (검증) 테스트 내에서 함수를 사용하는 검증 라이브러리
4) (리포터) 테스트 실행 결과를 보여 주는 테스트 리포터 역할

## 3. 단위 테스트 프레임워크가 제공하는 기능

제스트 같은 프레임워크를 사용하면 구체적으로 무엇이 달라질까요?

- 일관된 형식으로 테스트 코드를 작성할 수 있습니다.
- 새로운 테스트를 작성하는 작업을 쉽게 반복할 수 있습니다. 
- 테스트를 작성하기 쉬울수록 최대한 많은 부분을 점검하고 넘어갈 수 있으므로 큰 기능은 물론 우선 순위가 낮은 작은 기능까지 검증할 수 있어 버그가 생길 확률을 낮출 수 있습니다.
- 프레임워크의 리포팅 기능은 팀 차원에서 테스크를 관리하는 데 유용합니다. 테스트 통과 여부로 해당 작업의 성공 여부를 판단할 수 있습니다.

➔ 테스트 관련 작업을 효율화하기 때문에 시간을 투자해서 학습할 가치가 있습니다.

## 4. 비밀번호 검증 프로젝트

비밀번호 검증 함수를 테스트하는 코드를 작성합니다.

```js
// 매개변수, 반환 값
const verifyPassword = (input, rules) => {
  const errors = [];
  rules.forEach((rule) => {
    const result = rule(input);
    if (!result.passed) {
      errors.push(`error ${result.reason}`);
    }
  });
  return errors;
};

const oneUpperCaseRule = (input) => {
  return {
    passed: input.toLowerCase() !== input,
    reason: 'at least one upper case needed',
  };
};
```

## 5. verifyPassword() 함수의 첫 번째 테스트 코드

테스트 코드 작성 시에는 AAA 패턴(준비-실행-검증)을 활용할 수 있습니다. 준비 단계는 테스트에 필요한 변수를 초기화하는 단계입니다.

테스트 코드 이름을 작성할 때는 USE 전략을 활용할 수 있습니다.
- Unit: 테스트하려는 대상
- Scenario: 입력 값이나 상황에 대한 설명
- Expectation: 기댓값이나 결과에 대한 설명

```js
test('verifyPassword, given a failing rule, return errors', () => {
	const fakeRule = input => ({ passed: false, reason: 'fake reason' });

	const errors = verifyPassword('any value', [fakeRule]);

	expect(errors[0]).toContain('fake reason');
})
```

문자열 비교는 테스트에서 많이 활용되지만 유지 보수성이 다소 떨어집니다. 문자열 자체보다는 메시지가 담고 있는 의미가 중요합니다. 대신 정규 표현식을 사용하는 패턴이나 `toContain` 메서드를 사용하여 테스트 대상 코드가 변경되더라도 테스트가 실패하거나 거짓 양성이 발생할 가능성을 낮출 수 있습니다.

`describe` 함수를 사용해서 테스트 코드 구조를 체계적으로 나누어 관리할 수 있습니다.

`it` 함수는 `test` 함수의 별칭이며 더 명료한 의미를 전달합니다.

제스트에서는 테스트를 작성하는 두 가지 스타일이 있습니다:
1. `it` 함수를 사용하는 방식
2. 계층 구조를 이루는 `describe` 함수 중심의 방식 (중첩 스타일은 행동 주도 개발 스타일이라고도 합니다)

두 스타일을 섞어서 사용할 수도 있습니다.
- 테스트 대상과 상황이 명확할 때는 `it` 함수를 사용합니다.
- 동일한 시나리오, 동일한 진입점에 대해 여러 결과를 검증할 때는 `describe` 함수를 사용합니다.

## 6. `beforeEach()` 함수 사용

`beforeEach`와 `afterEach`는 각 테스트에 필요한 특정 상태를 설정하거나 해제할 수 있습니다. 각 테스트가 실행되기 전에 한 번씩 실행되기 때문에 코드 중복을 줄이는 데 도움이 됩니다.

제스트는 단위 테스트를 병렬로 실행하기 때문에 공유되는 상태를 만들고 이를 테스트하게 된다면, 하나의 테스트가 또 다른 테스트의 상태를 임의로 변경할 수 있습니다. 그리고 준비 단계에서 객체 또는 상태의 생성을 추적하며 테스트를 읽어야 하므로 스크롤 피로감이 발생할 수 있습니다.

## 7. 팩토리 함수 사용

팩토리 함수는 객체나 특정 상태를 쉽게 생성하고, 여러 곳에서 동일한 로직을 재사용할 수 있도록 도와주는 간단한 헬퍼 함수입니다.

팩토리 함수로 `beforeEach()` 함수를 완전히 대체할 수 있습니다. 
팩토리 함수를 사용한 테스트는 자체적으로 캡슐화되어 있어, `describe()` 함수는 코드 이해를 돕는 역할만 합니다.

```js
// v9 tests
test(
  'pass verifier, with failed rule, ' +
    'has an error message based on the rule.reason',
  () => {
    const verifier = makeVerifierWithFailedRule('fake reason');
    const errors = verifier.verify('any input');
    expect(errors[0]).toContain('fake reason');
  }
);

test('pass verifier, with failed rule, has exactly one error', () => {
  const verifier = makeVerifierWithFailedRule('fake reason');
  const errors = verifier.verify('any input');
  expect(errors.length).toBe(1);
});

test('pass verifier, with passing rule, has no errors', () => {
  const verifier = makeVerifierWithPassingRule();
  const errors = verifier.verify('any input');
  expect(errors.length).toBe(0);
});

test(
  'pass verifier, with passing and failing rule, has one error',
  () => {
    const verifier = makeVerifierWithFailedRule('fake reason');
    verifier.addRule(passingRule);
    const errors = verifier.verify('any input');
    expect(errors.length).toBe(1);
  }
);

test(
  'pass verifier, with passing and failing rule, error text belongs to failed rule',
  () => {
    const verifier = makeVerifierWithFailedRule('fake reason');
    verifier.addRule(passingRule);
    const errors = verifier.verify('any input');
    expect(errors[0]).toContain('fake reason');
  }
);

test('verify, with no rules, throws exception', () => {
  const verifier = makeVerifier();
  try {
    verifier.verify('any input');
    fail('error was expected but not thrown');
  } catch (e) {
    expect(e.message).toContain('no rules configured');
  }
});

test('verify, with no rules, throws exception', () => {
  const verifier = makeVerifier();
  expect(() => verifier.verify('any input')).toThrowError(
    /no rules configured/
  );
});
```

## 8. 다시 `test()` 함수로 돌아가기

`describe()` 함수는 테스트 코드를 캡슐화하는 역할을 합니다. `describe()` 함수를 사용하지 않더라도 팩토리 함수를 활용하여 AAA 패턴을 유지할 수 있습니다.

구조적인 명확성을 조금 잃을 수 있지만 테스트 코드를 더 간결하게 유지할 수 있습니다. 프로젝트의 유지 보수성과 가독성의 적절한 균형을 잡기 위해 테스트 코드를 작성할 때 적절한 스타일을 선택할 수 있습니다.

## 9. 다양한 입력 값을 받는 테스트 리팩터링

비슷한 입력 값을 반복적으로 사용하는 매개변수화 테스트는 매개변수를 배열과 같이 한데 묶어 하나의 테스트로 작성할 수 있습니다 필자는 단순한 방식을 좋아해 `test.each()` 함수를 사용합니다.

하지만 테스트를 일반화할수록 가독성이 떨어진다는 단점이 있습니다. 테스트 가독성과 코드 재사용성 사이의 균형을 잡기 위해 입력 값만 매개변수로 사용하고, 출력 값은 별도의 테스트로 작성하는 것이 좋습니다.


## 10. 예정된 오류가 발생하는지 확인

특정 시점에 적절한 데이터를 포함하여 오류를 발생시키는 코드를 설계해야 할 때가 있습니다. `try-catch` 구문을 사용할 수도 있지만 코드가 길어지고 작성이 번거롭습니다.

대부분의 테스트 프레임워크에서는 `expect().toThrowError()` 메서드를 지원합니다.

## 11. 테스트 카테고리 설정

특정 카테고리의 테스트만 실행하고 싶을 수 있습니다. 예를 들면, 단위 테스트, 통합 테스트, 특정 애플리케이션 부분 테스트가 있습니다.

제스트는 테스트 카테고리를 지원하지 않지만 `--testPathPattern` 플래그를 사용하여 특정 경로에 있는 테스트 그룹을 실행할 수 있습니다. 또한 설정 파일에서 `testRegex`를 설정하여 원하는 테스트 파일을 지정할 수 있습니다.

## Wrap Up

이번 장에서는 제스트를 사용하여 첫 번째 단위 테스트를 작성하는 방법을 알아보았습니다. 주요 내용을 정리하면 다음과 같습니다:

- 제스트는 테스트 작성, 실행, 검증, 결과 보고의 4가지 주요 기능을 제공합니다.
- AAA 패턴(준비-실행-검증)과 USE 전략(Unit-Scenario-Expectation)을 활용하여 체계적으로 테스트를 작성할 수 있습니다.
- `describe()`와 `it()` 함수를 사용하여 테스트 코드를 구조화할 수 있습니다.
- 팩토리 함수를 사용하면 테스트 객체 생성을 캡슐화하고 코드 재사용성을 높일 수 있습니다.
- `test.each()`를 사용한 매개변수화 테스트로 유사한 테스트 케이스를 효율적으로 작성할 수 있습니다.

### Summary

단위 테스트 프레임워크를 사용하면 일관된 형식으로 테스트를 작성하고, 테스트 실행을 자동화하며, 결과를 명확하게 확인할 수 있습니다. 제스트는 이러한 기능들을 제공하는 강력한 도구입니다.

테스트 코드를 작성할 때는 가독성과 유지보수성을 고려해야 합니다. 팩토리 함수나 매개변수화 테스트와 같은 기법을 적절히 활용하면 테스트 코드의 품질을 높일 수 있습니다. 하지만 과도한 추상화는 오히려 코드 이해를 어렵게 만들 수 있으므로, 프로젝트의 특성에 맞게 적절한 균형을 찾는 것이 중요합니다.

## Reference

- [단위 테스트의 기술](https://www.gilbut.co.kr/book/view?bookcode=BN004314)
- [단위 테스트의 기술 예제 코드](https://github.com/gilbutITbook/080410)


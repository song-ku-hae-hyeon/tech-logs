---
title: 퍼사드 패턴
description: 퍼사드 패턴은 복잡한 서브시스템에 대한 단순한 인터페이스를 제공하여 클라이언트 사용성을 높이는 구조 패턴입니다.
sidebar_position: 5
tags:
  - design-pattern
---

> 퍼사드 패턴은 라이브러리에 대한, 프레임워크에 대한 또는 다른 클래스들의 복잡한 집합에 대한 단순화된 인터페이스를 제공하는 구조적 디자인 패턴입니다.

## 의미

### 배경

- 여러가지 라이브러리와 프레임워크에 속한 객체들로 애플리케이션을 만들게되면, 그 객체들을 초기화하는 단계부터 시작하여 조합하는 과정들이 포함되게 됩니다.

- 실제 애플리케이션에서의 비즈니스 로직이 위의 과정들과 밀접하게 결합하게되면 코드를 유지보수하기 힘들어짐.


### 해결

- 애플리케이션에서 사용할 기능을 제한하여, 퍼사드라는 클래스가 하위 시스템들을 조합하여 그 기능을 제공하도록 합니다.


### 구조

<img width="500" alt="image" src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/71266602/ab92f446-d78b-4ebd-aac9-bf8feb3a1cda" />
- 퍼사드 클래스만 하위 시스템 기능들에 직접 접근할 수 있습니다.

- 클라이언트는 하위 시스템을 직접 호출하는 것이 아니라 퍼사드를 사용하여 애플리케이션을 동작 시킴.

## 코드

### Concept

```ts
class Facade {
    protected subsystem1: Subsystem1;

    protected subsystem2: Subsystem2;

    /**
     초기화시 실제 동작하는 하위 객체들을 넣어줄 수 있도록 함.
     */
    constructor(subsystem1?: Subsystem1, subsystem2?: Subsystem2) {
        this.subsystem1 = subsystem1 || new Subsystem1();
        this.subsystem2 = subsystem2 || new Subsystem2();
    }

    /**
     실제 동작에 필요한 하위 객체들의 메소드 조합으로 
     비즈니스 동작에 필요한 메소드 구현.
     */
    public operation(): string {
        let result = 'Facade initializes subsystems:\n';
        result += this.subsystem1.operation1();
        result += this.subsystem2.operation1();
        result += 'Facade orders subsystems to perform the action:\n';
        result += this.subsystem1.operationN();
        result += this.subsystem2.operationZ();

        return result;
    }
}

/**
하위 객체 1
 */
class Subsystem1 {
    public operation1(): string {
        return 'Subsystem1: Ready!\n';
    }

    // ...

    public operationN(): string {
        return 'Subsystem1: Go!\n';
    }
}

/**
 하위 객체 2
 */
class Subsystem2 {
    public operation1(): string {
        return 'Subsystem2: Get ready!\n';
    }

    // ...

    public operationZ(): string {
        return 'Subsystem2: Fire!';
    }
}

/**
 클라이언트 코드는 복잡한 조합이나 코드 필요없이 
 퍼사드로만 필요한 동작 수행
 */
function clientCode(facade: Facade) {
    // ...

    console.log(facade.operation());

    // ...
}

const subsystem1 = new Subsystem1();
const subsystem2 = new Subsystem2();
const facade = new Facade(subsystem1, subsystem2);
clientCode(facade);
```

- 책에서는 아래와 같은 비디오 컨버터를 예로 들고 있습니다.
```ts
// 이것들은 복잡한 타사 비디오 변환 프레임워크 클래스의 일부. 해당 프레임워크
// 코드는 우리가 제어할 수 없기 때문에 단순화할 수 없습니다.

class VideoFile
// …

class OggCompressionCodec
// …

class MPEG4CompressionCodec
// …

class CodecFactory
// …

class BitrateReader
// …

class AudioMixer
// …


// 퍼사드 클래스를 만들어 프레임워크의 복잡성을 간단한 인터페이스 뒤에 숨길 수
// 있음.
class VideoConverter is
// ...
```

### Use Case

- 실제로 사용할 경우 꼭 클래스일 필요는 없다고 생각합니다.
- 리액트 프로젝트에서 백엔드 데이터 요청시 흔히 fetcher 라이브러리와 비동기 상태관리 라이브러리를 조합해서 사용하게됨. 
- 아래 예시는 axios 와 react-query를 사용하여 데이터를 보여주는 컴포넌트

```tsx
const Example = (param) => {
  const fetcher = async () => {
    const res = await axios.get(`/examples`, {
      params
    });
    return res;
  };

  const { data, isError, isLoading } = useQuery({
    queryKey: ['EXAMPLE_LIST', param],
    queryFn: fetcher
  });

  return <div>{data?.content}</div>;
};
```

- Example 이라는 데이터를 받아오는 axios요청 함수 `fetcher` 를 만들고, react-query는 비동기 상태관리를 위한 데이터를 주고 있습니다.
- 위 컴포넌트에서만 사용할 경우에는 상관 없지만, 만약 다양한 컴포넌트에서 Example 데이터를 받아와서 사용해야 한다면 어떨까요?
- axios를 사용한 get 함수를 공통화한다고 하더라도(`getExamples`) 계속 `queryKey`와 `queryFn` 을 정의해 줘야 합니다. 리액트 쿼리를 공통화 하더라도 컴포넌트에서 굳이 알필요 없는 fetcher와 리액트 쿼리의 조합은 계속 반복됩니다.

```tsx
const useGetExamples = (param) => {
  const fetcher = async () => {
    const res = await getExamples(param); // axios 사용한 fetcher함수
    return res;
  };

  return useQuery({
    queryKey: [QUERY_KEY.EXAMPLE_LIST, param],
    queryFn: fetcher,
  });
};

```

- 클라이언트에서 사용할 퍼사드를 하나 두도록 합니다. 클라이언트에서 사용하는 Example을 받아오는 제한적인 기능만 하도록 구현되어 있으며, 결과적으로 클라이언트에서 사용할 `data`, `isLoading`, `isError` 등이 제공됩니다.

```tsx
const Example = (param) => {
  const { data, isError, isLoading } = useGetExamples(param);

  return <div>{data?.content}</div>;
};
```

- 이렇게 함으로써 복잡한 상호작용이 단순화되며 유지보수가 용이해짐.
- 이러한 구조 덕분에 나중에 라이브러리를 변경하더라도 최소한의 노력으로 결과를 달성할 수 있습니다.
- 왜냐하면 앱에서 바꿔야 할 부분은 퍼사드 내부일 뿐이기 때문입니다. 예를 들어 리액트쿼리 대신 swr을 사용하거나 axios 대신 기본 fetch 를 사용하더라도 클라이언트 코드에 변경은 없습니다.



## 적용

- 퍼사드 패턴은 복잡한 하위 시스템에 대해 제한적이고 간단한 인터페이스가 필요할 때 용이합니다.
- 하위 시스템들을 계층으로 구성하려는 경우 용이합니다. 여기서의 계층은 브릿지 패턴에서 언급했던 차원. 책에서는 비디오 변환 앱을 예로 들고 있습니다. 비디오 계층과 오디오 계층으로 나누어 각 계층에 대해 퍼사드를 만들 수 있습니다.

## Wrap Up
퍼사드 패턴은 Structural Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
퍼사드 패턴은 복잡한 서브시스템에 대한 단순한 인터페이스를 제공하여 클라이언트 사용성을 높이는 구조 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)

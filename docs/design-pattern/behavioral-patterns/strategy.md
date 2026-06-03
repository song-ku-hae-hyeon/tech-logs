---
title: 전략 패턴
description: 전략 패턴은 알고리즘을 별도 전략 객체로 분리하여 런타임에 객체의 동작을 교체할 수 있게 하는 행동 패턴입니다.
sidebar_position: 5
tags:
  - design-pattern
---

> **전략 패턴**이란 런타임에 알고리즘 전략을 선택하여 객체 동작을 변경할 수 있게 하는 행동 디자인 패턴

### Problem

지도 앱의 자동 경로 계획 기능 → 주소를 입력하면 해당 목적지까지의 최단 경로를 보여줌
처음에는 도로로 된 경로만 제공합니다. 시간이 지나면서 도보, 대중교통, 자전거 등 다양한 수단을 활용한 기능 제공이 필요해집니다.

- 새 경로 구축 알고리즘 추가 시 메인 클래스의 크기가 두 배로 늘어남
- 간단한 버그 수정의 영향 범위가 큼
- 한 클래스의 수정이 타 클래스의 수정에도 영향을 줌

### Solution

- 특정 작업을 다양한 방식으로 수행하는 기능을 Strategy Class로 추출합니다.
- 작업 실행을 Strategy Class에 위임하기 위한 Context Class를 선언합니다.

### Implementation

```ts
class Context {
  private strategy: Strategy;

  setStrategy(strategy: Strategy) {
    this.strategy = strategy;
  }

  executeStrategy() {
    this.strategy.execute();
  }
}

interface Strategy {
  execute(): void;
}

class TransporationStrategy implements Strategy {
  execute(): void {
    console.log("Transporation Strategy Execute");
  }
}
class DriverStrategy implements Strategy {
  execute(): void {
    console.log("Driver Strategy Execute");
  }
}

class PedestrianStrategy implements Strategy {
  execute(): void {
    console.log("Pedestrian Strategy Execute");
  }
}

(() => {
  const context = new Context();
  const strategy = getStrategy();

  switch (strategy) {
    case "transportation":
      context.setStrategy(new TransporationStrategy());
      context.executeStrategy();
      return;
    case "driver":
      context.setStrategy(new DriverStrategy());
      context.executeStrategy();
      return;
    case "pedestrian":
      context.setStrategy(new PedestrianStrategy());
      context.executeStrategy();
      return;
  }
})();

function getStrategy(): "transportation" | "driver" | "pedestrian" {
  const stragey: "transportation" | "driver" | "pedestrian" = "transportation";
  return stragey;
}
```

### When to use

- 런타임 중에서 알고리즘 전환하고 싶은 경우
- 일부 행동을 실행하는 방식에서만 차이가 있는 유사한 클래스가 많은 경우

## Wrap Up
전략 패턴은 Behavioral Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
전략 패턴은 알고리즘을 별도 전략 객체로 분리하여 런타임에 객체의 동작을 교체할 수 있게 하는 행동 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)

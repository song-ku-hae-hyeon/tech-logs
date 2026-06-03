---
title: 프록시 패턴
description: 프록시 패턴은 원래 객체에 대한 대체 객체를 두어 접근 제어, 캐싱, 지연 초기화 같은 처리를 추가하는 구조 패턴입니다.
sidebar_position: 7
tags:
  - design-pattern
---

> 다른 객체에 대한 대체 또는 자리표시자를 제공할 수 있는 구조 디자인 패턴. 원래 객체에 대한 접근을 제어하므로, 원래 객체에 전달되기 전 또는 후에 무언가를 수행할 수 있습니다.

## 문제

<img src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/50704533/92e6a7f3-4d0d-44bd-8f29-db6e354e75a3" width="400" />
필요할 때에만 사용할 수 있도록 객체에 대한 접근을 제한하고 싶습니다.
지연된 초기화를 구현? 코드 중복을 초래합니다.
이 코드를 객체의 클래스에 넣으면 되지 않을까요? 폐쇄된 타사 라이브러리라면 불가능합니다.

## 해결책

원래 서비스 객체와 <b>같은 인터페이스</b>로 새 프록시 클래스를 생성하라고 제안합니다. 프록시 객체를 원래 객체의 모든 클라이언트들에 전달하도록 앱을 업데이트할 수 있습니다. 클라이언트로부터 요청을 받으면 이 프록시는 실제 서비스 객체를 생성하고 모든 작업을 이 객체에 위임합니다.

<img src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/50704533/bd42100a-d619-4bd9-b28f-a1f27ddffdf1" width="400" />
프록시는 데이터베이스 객체로 자신을 변장합니다. 프록시는 지연된 초기화 및 결괏값 캐싱을 클라이언트와 실제 데이터베이스 객체가 <b>알지 못하는</b> 상태에서 처리할 수 있습니다.

이는 클래스의 메인 로직 이전이나 이후에 무언가를 실행해야 하는 경우 프록시는 해당 클래스를 변경하지 않고도 이 무언가를 수행할 수 있도록 합니다. 프록시는 원래 클래스와 같은 인터페이스를 구현하므로 실제 서비스 객체를 기대하는 모든 클라이언트에 전달될 수 있습니다.

## 실제상황 적용

<img src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/50704533/54a95832-ad96-4ba6-984a-417ba5f6c215" width="400" />
신용카드는 은행 계좌의 프록시이며, 은행 계좌는 현금의 프록시. (결국 신용카드는 현금의 프록시다) 신용카드는 현금을 들고 다닐 필요가 없는 장정이 있습니다. 둘 다 같은 인터페이스를 구현하며 둘 다 결제에 사용될 수 있습니다.

## 구조

<img src="https://github.com/song-ku-hae-hyeon/Dive-into-Design-Pattern/assets/50704533/e0768584-299e-42e7-bee4-be6722c94f16" width="400" />
1. 프록시는 이 인터페이스(서비스 클래스와 동일)를 따라야 합니다.
2. 비즈니스 로직을 제공하는 클래스
3. 서비스 객체를 가리키는 참조 필드가 있습니다. 프록시가 요청의 처리(e.g. 초기화 지연, 로깅, 액세스 제어, 캐싱 등) 완료하면, 그 후 처리된 요청을 서비스 객체에 위임합니다. 일반적으로 프록시들은 서비스 객체들의 전체 수명 주기를 관리합니다.
4. 같은 인터페이스를 통해 서비스들 및 프록시들과 함께 작동해야 합니다. 그러면 서비스 객체를 기대하는 모든 코드에 프록시를 전달할 수 있기 때문입니다.

## 코드

```ts
interface ThirdPartyYouTubeLib {
  listVideos();
  getVideoInfo(id);
}

class ThirdPartyYouTubeClass implements ThirdPartyYouTubeLib {
  listVideos(): any[] {
    // api 요청
    return [];
  }

  getVideoInfo(id: any): any {
    // 메타데이터 요청
  }
}

class CachedYouTubeClass implements ThirdPartyYouTubeLib {
  private service: ThirdPartyYouTubeClass;
  private listCache: any[];
  private videoCache: Map<string, any>;

  constructor(service: ThirdPartyYouTubeClass) {
    this.service = service;
  }

  listVideos() {
    if (this.listCache.length) {
      return this.listCache;
    }
    const list = this.service.listVideos();
    this.listCache = list;
    return list;
  }

  getVideoInfo(id: any) {
    if (this.videoCache.has(id)) {
      return this.videoCache.get(id);
    }
    const videoInfo = this.service.getVideoInfo(id);
    this.videoCache.set(id, videoInfo);
    return videoInfo;
  }
}

class YouTubeManager {
  private service: ThirdPartyYouTubeLib;

  constructor(service: ThirdPartyYouTubeLib) {
    this.service = service;
  }

  renderVideoPage(id) {
    const info = this.service.getVideoInfo(id);
    // info를 기반으로 렌더링
  }

  renderListPanel() {
    const list = this.service.listVideos();
    // list를 기반으로 렌더링
  }

  reactOnUserInput() {
    this.renderVideoPage(1234);
    this.renderListPanel();
  }
}

class Application {
  init() {
    const aYouTubeService = new ThirdPartyYouTubeClass();
    const aYouTubeProxy = new CachedYouTubeClass(aYouTubeService);
    const manager = new YouTubeManager(aYouTubeProxy);
    // const manager = new YouTubeManager(aYouTubeService)
    // 물론 원래 객체로도 가능할 것입니다 (동일한 인터페이스를 구현했기 때문)

    manager.reactOnUserInput();
  }
}
```

## 용도들

패턴이 가장 많이 사용되는 용도들 위주로 살펴보자.

### 지연된 초기화(가상 프록시)

어쩌다 필요한 무거운 서비스 객체가 항상 가동되어 있어 시스템 자원들을 낭비하는 경우 사용됩니다.

### 접근 제어 (보호 프록시)

특정 클라이언트들만 서비스 객체를 사용할 수 있도록 할 때 사용됩니다.

### 원격 서비스의 로컬 실행 (원격 프록시)

서비스 객체가 원격 서버에 있는 경우 사용됩니다. 네트워크를 통해 클라이언트 요청을 전달하여 네트워크와의 작업의 모든 복잡한 세부 사항을 처리합니다. (Java RMI에 녹아있으며, RPC가 프로세스 간의 호출이라면 Java RMI는 JVM 간의 호출)

### 요청 결과들의 캐싱 (캐싱 프록시)

클라이언트 요청들의 결과들을 캐시하고 이 캐시들의 수명 주기를 관리해야 할 때 사용됩니다. (특히 결과들이 상당히 클 때)

### 스마트 참조

사용하는 클라이언트들이 없어 거대한 객체를 해제할 수 있어야 할 때 사용됩니다. 때때로 클라이언트들을 점검하여 여전히 활성 상태인지를 확인할 수 있습니다. 클라이언트 리스트가 비어 있으면 프록시는 해당 서비스 객체를 닫고 그에 해당하는 시스템 자원을 확보할 수 있습니다.

## 장단점

### 장점

- 클라이언트들이 알지 못하는 상태에서 서비스 객체를 제어할 수 있습니다.
- 클라이언트들이 신경 쓰지 않을 때 서비스 객체의 수명 주기를 관리할 수 있습니다.
- 프록시는 서비스 객체가 준비되지 않았거나 사용할 수 없는 경우에도 작동합니다.
- 개방/폐쇄 원칙. 서비스나 클라이언트들을 변경하지 않고도 새 프록시들을 도입할 수 있습니다.

### 단점

- 새로운 클래스들을 많이 도입해야 하므로 코드가 복잡해집니다.
- 서비스의 응답이 늦어질 수 있습니다.

## 참고 자료

- [proxy를 프락시로 불러야 할지..?](https://www.korean.go.kr/front/search/searchAllList.do?allSearchQuery=proxy&searchQuery=proxy&reSearchCheck=&searchCategory=know4&searchScope=total&searchPeriod=&searchStartDate=&searchEndDate=&searchSize=10&currentPage=1&searchSort=weight)
- [Java RMI 간단 예제](https://gogetem.tistory.com/entry/Java-RMI-Remote-Method-Invokation%EC%9D%84-%EC%95%8C%EC%95%84%EB%B3%B4%EC%9E%90)

## Wrap Up
프록시 패턴은 Structural Patterns에 속하는 디자인 패턴입니다. 원문에서 다룬 문제 상황, 해결 구조, TypeScript 예제를 중심으로 핵심 흐름을 정리했습니다.

### Summary
프록시 패턴은 원래 객체에 대한 대체 객체를 두어 접근 제어, 캐싱, 지연 초기화 같은 처리를 추가하는 구조 패턴입니다. 원문 코드와 용어 설명을 최대한 유지하여 패턴의 의도와 적용 지점을 함께 확인할 수 있도록 구성했습니다. 실제 적용 시에는 클라이언트 코드가 구상 클래스에 직접 의존하는 정도, 책임이 한 클래스에 몰리는 정도, 런타임에 조합이 필요한지 여부를 함께 살펴보는 것이 좋습니다.

### Reference
- [Refactoring.guru](https://refactoring.guru/)

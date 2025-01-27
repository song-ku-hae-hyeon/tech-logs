---
title: Start the course
description: 오류 메시지 작성의 필요성에 대해 다룹니다.
sidebar_position: 0
tags:
  - technical-writing
---

## Writing Helpful Error Messages

### Target audience for this course
이 과정은 다음과 같은 직군을 대상으로 합니다.

- 엔지니어
- 프로덕트 매니저
- 테크니컬 라이터

오류 메시지 코스를 수강하기 전에 [Technical Writing One](https://developers.google.com/tech-writing/overview) 코스 수강을 권장합니다. 
좋은 오류 메시지는 좋은 기술 문서 작성의 또 다른 형태이기에 우선 좋은 기술 문서 작성을 이해하는 것이 좋습니다.

### Why take this course?

나쁜 오류 메시지는 사용자를 혼란스럽게 합니다. 반면에 좋은 에러 메시지는 예상대로 동작하지 않을 때 중요한 정보를 제공합니다. 

오류 메시지는 문제가 발생했을 때 개발자와 사용자가 소통하는 주요 수단인 경우가 많습니다. 따라서 사용자가 다음에 수행할 수 있도록 도와주는 것이 중요합니다.

Google 지원 시스템 및 UX 연구에서는 다음과 같은 잘못된 오류 메시지의 일반적인 문제를 확인했습니다.

- 원인이 불명확합니다.
- 모호하며 혼란을 야기합니다.
- 해결을 위한 사용자 액션을 안내하지 않습니다.

반대로, 좋은 오류 메시지는 다음과 같은 특징을 가지고 있습니다.

- 사용자가 스스로 도울 수 있도록 합니다. 
- 최고의 사용자 경험을 제공합니다.
- 지원 업무량을 줄입니다. 
- 문제를 더 빨리 해결할 수 있도록 합니다.

### Learning objectives

코스를 수강하고 나면 다음을 수행하는 방법을 알게 됩니다. 

- 명확하고 도움이 되는 오류 메시지를 작성하는 방법을 이해합니다.
- 팀원의 오류 메시지를 리뷰할 수 있습니다.

## General error handling rules

오류 메시지 작성에 대해 알아보기 전에 몇 가지 일반적인 오류 처리 규칙에 대해 알아보겠습니다.

### Don't fail silently

실패는 피할 수 없으며 실패를 보고하지 않는 것은 변명의 여지가 없습니다. 
조용한 실패는 사용자를 궁금하게 만들고, 고객 지원팀의 업무량을 증가시킵니다.

소프트웨어의 오류 가능성을 인정하세요. 사람이 소프트웨어를 사용하면서 실수를 할 수 있다고 가정하세요. 
사람들이 소프트웨어를 오용할 수 있는 방법을 최소화하려고 노력하되, 오용을 완전히 없앨 수는 없다고 가정하세요. 
따라서 소프트웨어를 설계할 때 오류 메시지를 계획하고 구현하세요.

### Follow the programming language guides

구글 프로그래밍 언어 가이드에 따라 오류 메시지를 작성하세요. 

- [Google C++ Style Guide](https://google.github.io/styleguide/cppguide.html)
- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html)
- [Google JavaScript Style Guide](https://google.github.io/styleguide/jsguide.html)
- [Google Go Style Guide](https://google.github.io/styleguide/go/index.html)

### Implement the full error model

[Google AIP](https://google.aip.dev/193)의 오류 페이지에 설명된 전체 오류 모델을 구현하세요. 예를 들어 서비스에서 오류 메시지를 구현할 때 다음 인용문을 참고하세요. 

> 서비스는 API 오류가 발생하면 google.rpc.Status 메시지를 반환해야 하며 google.rpc.Code에 정의된 표준 오류 코드를 사용해야 합니다.

[Google Cloud API 디자인 가이드의 오류 페이지](https://cloud.google.com/apis/design/errors?hl=ko)에서는 Google API의 전체 오류 모델을 구현하는 데 유용한 정보를 제공합니다.

### Avoid swallowing the root cause

API 구현이 백엔드에서 발생하는 문제의 근본 원인을 간과해서는 안 됩니다. 예를 들어 다음과 같은 다양한 상황에서 '서버 오류' 문제가 발생할 수 있습니다. 

- 서비스 장애
- 네트워크 연결 끊김
- 상태 불일치
- 권한 이슈

서버 오류는 너무 일반적인 오류 메시지로 사용자가 문제를 이해하고 해결하는 데 도움이 되지 않습니다. 
서버 로그에 세션 내 사용자 및 작업에 대한 식별 정보가 포함되어 있는 경우 특정 장애 사례에 대한 추가 컨텍스트를 제공하는 것이 좋습니다.

### Log the error codes

숫자 오류 코드는 고객 지원팀이 오류를 모니터링하고 진단하는 데 도움이 됩니다. 
내부 오류와 외부 오류 모두에 대해 오류 코드를 지정할 수 있습니다. 
내부 오류의 경우 내부 지원 담당자 및 엔지니어가 쉽게 조회/디버깅할 수 있도록 적절한 오류 코드를 제공하세요. 

### Raise errors immediately

최대한 빨리 오류를 발생시키세요. 오류를 보류했다가 나중에 올리면 디버깅 비용이 크게 증가합니다.

## Wrap Up
오류 메시지는 사용자와 개발자 간의 중요한 소통 수단입니다. 
좋은 오류 메시지를 작성하기 위해서는 다음과 같은 기본 규칙을 따라야 합니다:

- 조용한 실패를 피하고 항상 오류를 보고합니다
- 프로그래밍 언어별 스타일 가이드를 따릅니다
- 완전한 오류 모델을 구현합니다
- 근본 원인을 무시하지 않습니다
- 오류 코드를 로깅합니다
- 오류를 즉시 발생시킵니다

### Summary
이 장에서는 오류 메시지의 중요성과 기본적인 오류 처리 규칙에 대해 알아보았습니다. 
좋은 오류 메시지는 사용자 경험을 향상시키고, 문제 해결 시간을 단축하며, 지원 업무량을 줄일 수 있습니다. 
다음 장에서는 실제로 도움이 되는 오류 메시지를 작성하는 방법에 대해 자세히 알아보겠습니다.


### Reference
- [Google Tech Writing Error Messages Course](https://developers.google.com/tech-writing/error-messages)
- [Google AIP Error Model](https://google.aip.dev/193)
- [Google Cloud API Design Guide - Errors](https://cloud.google.com/apis/design/errors?hl=ko)
- [Google Style Guides](https://google.github.io/styleguide/)

---
title: Explain the problem
description: 오류 메시지에서 문제를 설명하는 방법에 대해 다룹니다.
sidebar_position: 1
tags:
  - technical-writing
---

## Identify the error's cause

사용자에게 정확히 무엇이 잘못되었는지 알려주세요. 구체적이어야 합니다. 모호한 오류 메시지는 사용자를 혼란스럽게 만듭니다.

### Examples

디렉터리 권한 문제를 모호하게 설명하는 대신 디렉터리가 존재하지만 쓰기 권한이 없다는 것을 구체적으로 설명하는 예시입니다:

:::danger[Not recommended]
Bad directory.
:::

:::tip[Recommended]
The [Name of directory] directory exists but is not writable. To add files to this directory, the directory must be writable. [Explanation of how to make this directory writable.]
:::

<br />

다음은 명령줄 입력 오류를 설명하는 예시입니다:

:::danger[Not recommended]
Invalid field 'picture'.
:::

:::tip[Recommended]
The 'picture' field can only appear once on the command line; this command line contains the 'picture' field 2 times.
:::

## Identify the user's invalid inputs

오류에 사용자가 입력하거나 수정할 수 있는 값이 포함된 경우, 오류 메시지는 문제가 되는 값을 명시해야 합니다.

잘못된 입력이 여러 줄에 걸쳐 매우 긴 경우에는 다음 중 하나를 고려하세요. 
- 잘못된 입력을 점진적으로 표시합니다.
- 잘못된 입력은 필수 부분만 남겨두고 나머지는 생략합니다.

### Examples

다음은 금융 거래 시스템에서 국가 간 송금 제한을 설명하는 예시입니다:

:::danger[Not recommended]
Funds can only be transferred to an account in the same country.
:::

:::tip[Recommended]
You can only transfer funds to an account within the same country. Sender account's country (UK) does not match the recipient account's country (Canada).
:::

<br />

다음은 우편번호 입력 오류를 설명하는 예시입니다:

:::danger[Not recommended]
Invalid postal code.
:::

:::tip[Recommended]
The postal code for the US must consist of either five or nine digits.   
The specified postal code (4872953) contained seven digits.
:::


## Specify requirements and constraints 

사용자가 요구 사항과 제약 조건을 이해하도록 도와주세요.
사용자가 시스템의 한계를 알고 있다고 가정하지 마세요.

### Examples

다음은 파일 첨부 크기 제한을 설명하는 예시입니다:

:::danger[Not recommended]
The combined size of the attachments is too big.
:::

:::tip[Recommended]
The combined size of the attachments (14MB) exceeds the allowed limit (10MB). [Details about possible solution.]
:::

<br />

다음은 권한 관련 오류를 설명하는 예시입니다:

:::danger[Not recommended]
Permission denied.
:::

:::tip[Recommended]
Permission denied. Only users in the admin group have access. [Details about adding users to the group.]
:::

<br />

다음은 시간 초과 오류를 설명하는 예시입니다:

:::danger[Not recommended]
Time-out period exceeded.
:::

:::tip[Recommended]
Time-out period (30s) exceeded. [Details about possible solution.]
:::


## Wrap up

오류 메시지에서 문제를 설명할 때는 다음 세 가지 핵심 원칙을 기억하세요: 

- 오류의 정확한 원인을 식별하고 구체적으로 설명합니다
- 잘못된 사용자 입력이 있다면 명확히 지적합니다
- 시스템의 요구사항과 제약조건을 명시적으로 안내합니다

### Summary

이 장에서는 오류 메시지에서 문제를 효과적으로 설명하는 방법을 알아보았습니다.  
문제 원인을과 잘못된 입력값을 명확히 안내하고, 제약사항을 명확하게 전달하는 것이 중요합니다.  
이를 통해 사용자는 문제를 더 잘 이해하고 해결할 수 있습니다. 

### References
- [Google Tech Writing Error Messages Course- Explain the problem](https://developers.google.com/tech-writing/error-messages/identify-the-cause)
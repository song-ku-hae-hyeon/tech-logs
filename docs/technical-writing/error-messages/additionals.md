---
title: Additionals for BE engineers
description: 백엔드 엔지니어를 위한 추가 가이드를 소개합니다.
sidebar_position: 4
tags:
  - technical-writing
---

## Additional guidelines for back-end engineers

백엔드 엔지니어를 위한 추가 가이드를 소개합니다.

### Supply error codes

- 에러코드가 존재하면, 에러 메시지에 포함시킵니다.
  :::danger[bad]
  Error: You already own this bucket. Select another name from the dropdown list.
  :::
  :::tip[good]
  Error 409: You already own this bucket. Select another name from the dropdown list.
  :::

### Include an Error Identifier

- 에러 식별자를 포함시키면 에러를 찾는데 도움이 됩니다.
  :::danger[bad]
  Bad Request - Request is missing a required parameter: -collection_name. Update parameter and resubmit.
  :::
  :::tip[good]
  Bad Request - Request is missing a required parameter: -collection_name. Update parameter and resubmit. Issue Reference Number BR0x0071
  :::

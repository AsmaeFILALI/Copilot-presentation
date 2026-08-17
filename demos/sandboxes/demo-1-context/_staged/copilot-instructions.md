# Project conventions

- TypeScript, strict mode. No `any`.
- Money is always `Money` (minor units + currency). Never a bare `number`.
- Functions that can fail return `Result<T>`. **Never throw** for domain errors.
- Error values are SCREAMING_SNAKE_CASE string codes.
- No default exports.

# REL-004 — Database unavailable

**Status:** **Promoted** — closed study: [../database-unavailable/](../database-unavailable/)

## Question

How does analyze behave when SQL Server is unreachable?

## Method

iptables REJECT on `:1433` (mssql stays running); probe Claim Studio Analyze + `/api/terminal/diag`.

## Record results in

`investigations/database-unavailable/results/` (ran 2026-07-12).

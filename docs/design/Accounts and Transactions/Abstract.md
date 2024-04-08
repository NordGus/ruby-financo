# Abstract

## Designing financo's core: Accounts and Transactions.

The way Accounts and Transactions are designed is like a graph, where Accounts
are the graph's nodes, and the Transactions are its edges.

<img src="Account-Abstract.drawio.svg" alt="diagram">

## Accounts
Accounts are containers that can represent a capital store or wallet in the
system, debts held or incurred, available credit or any source of income or
expense.

| field       | type      | additional                           |
|-------------|-----------|--------------------------------------|
| id          | uuid      | primary key                          |
| parent_id   | uuid      | index                                |
| kind        | text      | index, not nullable                  |
| currency    | text      | index, not nullable                  |
| name        | text      | not nullable                         |
| description | text      |                                      |
| color       | text      | not nullable                         |
| icon        | text      | not nullable                         |
| limit       | integer   | not nullable, default `0`            |
| is_archived | boolean   | index, not nullable, default `false` |
| created_at  | timestamp | not nullable                         |
| updated_at  | timestamp | not nullable                         |
| deleted_at  | timestamp | index                                |

An Account can have a parent account vía the `parent_id`.
This is a design decision made, so the user can define child accounts,
so they can better classify their finances inside the system's limitations.

Every Account must have a `kind`, that will be treated as an enum to indicate
the type of account stored in the system.
The values should be defined as `{family}.{type}`.
Where family would be one of the following `system`, `capital`, `debt`,
`external`.
As for the types, each family would have their own:
- `system`
  - `history`
- `capital`
  - `normal`
  - `savings`
- `debt`
  - `loan`
  - `credit`
- `external`
  - `income`
  - `expense`

This should be enforced on a database level.

All Accounts must have a `currency`, that will be treated as an enum, or at
least be normalized to a defined list of values to indicate the `currency`
stored or handled by the account stored in the system.
This would indicate the system if the user should indicate the amount received
by the target account to store as the transaction's exchange rate and maintain
system coherency.

Accounts must have a `limit`, this value will be used on `debt` family Accounts 
to define the credit limit for `debt.credit` Accounts or the amount owed/own for
`debt.loan` Accounts.
For all other Accounts' `kind` this value should be `0` for normalization
purposes and for future flexibility.

The field `is_archive` is a mechanism to communicate that an Account is no
longer in use or closed, but all transactions to and from it continue to be
present in the transaction listings.
Being a `boolean` field it can't be `null` and by default it should be `false`.

For deletion, each Account can have a timestamp `deleted_at` to indicate it was
deleted form the system, and it will be completely removed on later time.

## Transactions
Transactions are time series-like records that connect money movements between
[Accounts](#accounts).

| field         | type      | additional                                   |
|---------------|-----------|----------------------------------------------|
| id            | uuid      | primary key                                  |
| source_id     | uuid      | foreign key to accounts, index, not nullable |
| target_id     | uuid      | foreign key to accounts, index, not nullable |
| source_amount | integer   | not nullable                                 |
| target_amount | integer   | not nullable                                 |
| notes         | text      |                                              |
| issued_at     | date      | index, not nullable                          |
| executed_at   | date      | index                                        |
| created_at    | timestamp | not nullable                                 |
| updated_at    | timestamp | not nullable                                 |
| deleted_at    | timestamp | index                                        |

All Transactions need to reference a *Source* Account and a *Target* Account,
vía `source_id` and `target_id`.
These relations need to be validated to prevent a circular reference where
*Source* Account and *Target* Account are the same.

As well, every Transaction, needs to include a `source_amount` and
`target_amount` fields to store the Transaction's amount, the reason there are
two separate values, is because the *Source* Account and the *Target* Account
not necessarily share the same `currency`, so this is used to store the
Transaction's effective conversion rate.
So, if *Source* Account and *Target* Account share the same `currency` both,
`source_amount` and `target_amount`, must be equal.
And if *Source* Account and *Target* Account `currency` are different,
`source_account` and `target_amount` should be different,
storing the amounts for each Account `currency` of the Transaction.

Every Transaction must have an `issued_at` date, this date represents the date 
that the Transaction was issued from the *Source* Account, ergo when the money
left.

At the same time it also have a `executed_at` date, this date represents
the date that the Transaction was executed by the *Target* Account's
institution, ergo when the money arrived.

The difference between `issued_at` and `executed_at` represents the lag time
of the Transaction.

For deletion, each Account can have a timestamp `deleted_at` to indicate it was
deleted form the system, and it will be completely removed on later time.

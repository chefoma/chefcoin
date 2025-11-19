;; Chefcoin fungible token smart contract
;; Simple SIP-010-like FT with owner-only minting

(define-trait ft-trait
  (
    (transfer (uint principal principal (optional (buff 34))) (response bool uint))
    (get-balance (principal) (response uint uint))
    (get-total-supply () (response uint uint))
    (get-name () (response (string-ascii 32) uint))
    (get-symbol () (response (string-ascii 10) uint))
    (get-decimals () (response uint uint))
    (get-token-uri () (response (optional (string-utf8 256)) uint))
  )
)

;; error codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-INSUFFICIENT-BALANCE u101)
(define-constant ERR-INVALID-AMOUNT u102)

;; token constants
(define-constant TOKEN-NAME "Chefcoin")
(define-constant TOKEN-SYMBOL "CHEF")
(define-constant TOKEN-DECIMALS u6)

;; contract owner (default devnet deployer from settings/Devnet.toml)
(define-constant CONTRACT-OWNER 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)

;; data storage
(define-data-var total-supply uint u0)
(define-map balances { owner: principal } { balance: uint })

;; helpers
(define-private (get-balance-or-zero (owner principal))
  (default-to u0 (get balance (map-get? balances { owner: owner })))
)

;; read-only functions
(define-read-only (get-name)
  (ok TOKEN-NAME)
)

(define-read-only (get-symbol)
  (ok TOKEN-SYMBOL)
)

(define-read-only (get-decimals)
  (ok TOKEN-DECIMALS)
)

(define-read-only (get-total-supply)
  (ok (var-get total-supply))
)

(define-read-only (get-balance (owner principal))
  (ok (get-balance-or-zero owner))
)

(define-read-only (get-token-uri)
  ;; no on-chain metadata URI for now
  (ok none)
)

;; core public functions
(define-public (transfer (amount uint)
                         (sender principal)
                         (recipient principal)
                         (memo (optional (buff 34))))
  (if (is-eq amount u0)
      (err ERR-INVALID-AMOUNT)
      (let
        (
          (sender-balance (get-balance-or-zero sender))
        )
        (if (>= amount sender-balance)
            (err ERR-INSUFFICIENT-BALANCE)
            (begin
              ;; debit sender
              (map-set balances
                { owner: sender }
                { balance: (- sender-balance amount) })

              ;; credit recipient
              (let
                (
                  (recipient-balance (get-balance-or-zero recipient))
                )
                (map-set balances
                  { owner: recipient }
                  { balance: (+ recipient-balance amount) })
              )

              (ok true)
            )
        )
      )
  )
)

(define-public (mint (amount uint) (recipient principal))
  (if (not (is-eq tx-sender CONTRACT-OWNER))
      (err ERR-NOT-AUTHORIZED)
      (if (is-eq amount u0)
          (err ERR-INVALID-AMOUNT)
          (let
            (
              (current-supply (var-get total-supply))
              (recipient-balance (get-balance-or-zero recipient))
            )
            ;; update total supply
            (var-set total-supply (+ current-supply amount))

            ;; update recipient balance
            (map-set balances
              { owner: recipient }
              { balance: (+ recipient-balance amount) })

            (ok true)
          )
      )
  )
)

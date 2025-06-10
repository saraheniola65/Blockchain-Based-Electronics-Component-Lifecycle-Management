;; End-of-Life Management Contract
;; Manages component end-of-life processes

(define-data-var admin principal tx-sender)

;; EOL status constants
(define-constant EOL-STATUS-PENDING u1)
(define-constant EOL-STATUS-APPROVED u2)
(define-constant EOL-STATUS-RECYCLING-SCHEDULED u3)
(define-constant EOL-STATUS-RECYCLED u4)

;; Map to store EOL requests
(define-map eol-requests
  { component-id: (string-ascii 32) }
  {
    requester: principal,
    request-date: uint,
    reason: (string-ascii 128),
    status: uint,
    approver: (optional principal),
    approval-date: (optional uint)
  }
)

;; Map to store component lifespan expectations
(define-map component-lifespan
  { component-type: (string-ascii 32) }
  {
    expected-lifespan: uint,  ;; in blocks
    recommended-replacement: (string-ascii 32)
  }
)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Request end-of-life for a component
(define-public (request-eol
    (component-id (string-ascii 32))
    (reason (string-ascii 128)))
  (begin
    (asserts! (is-none (map-get? eol-requests { component-id: component-id })) (err u2))

    (ok (map-set eol-requests
      { component-id: component-id }
      {
        requester: tx-sender,
        request-date: block-height,
        reason: reason,
        status: EOL-STATUS-PENDING,
        approver: none,
        approval-date: none
      }
    ))
  )
)

;; Approve EOL request (admin only)
(define-public (approve-eol-request (component-id (string-ascii 32)))
  (begin
    (asserts! (is-admin) (err u1))

    (match (map-get? eol-requests { component-id: component-id })
      request
        (ok (map-set eol-requests
          { component-id: component-id }
          (merge request {
            status: EOL-STATUS-APPROVED,
            approver: (some tx-sender),
            approval-date: (some block-height)
          })
        ))
      (err u3)
    )
  )
)

;; Update EOL status
(define-public (update-eol-status
    (component-id (string-ascii 32))
    (new-status uint))
  (begin
    (asserts! (is-admin) (err u1))

    (match (map-get? eol-requests { component-id: component-id })
      request
        (ok (map-set eol-requests
          { component-id: component-id }
          (merge request {
            status: new-status
          })
        ))
      (err u3)
    )
  )
)

;; Set component lifespan expectations (admin only)
(define-public (set-component-lifespan
    (component-type (string-ascii 32))
    (expected-lifespan uint)
    (recommended-replacement (string-ascii 32)))
  (begin
    (asserts! (is-admin) (err u1))

    (ok (map-set component-lifespan
      { component-type: component-type }
      {
        expected-lifespan: expected-lifespan,
        recommended-replacement: recommended-replacement
      }
    ))
  )
)

;; Get EOL request details
(define-read-only (get-eol-request (component-id (string-ascii 32)))
  (map-get? eol-requests { component-id: component-id })
)

;; Get component lifespan expectations
(define-read-only (get-component-lifespan (component-type (string-ascii 32)))
  (map-get? component-lifespan { component-type: component-type })
)

;; Check if component has exceeded expected lifespan
(define-read-only (has-exceeded-lifespan
    (component-type (string-ascii 32))
    (manufacture-date uint))
  (match (map-get? component-lifespan { component-type: component-type })
    lifespan
      (ok (> block-height (+ manufacture-date (get expected-lifespan lifespan))))
    (err u4)
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u1))
    (ok (var-set admin new-admin))
  )
)

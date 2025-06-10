;; Component Tracking Contract
;; Tracks electronic components throughout their lifecycle

(define-data-var admin principal tx-sender)

;; Component status enum
(define-constant STATUS-MANUFACTURED u1)
(define-constant STATUS-SHIPPED u2)
(define-constant STATUS-INSTALLED u3)
(define-constant STATUS-MAINTENANCE u4)
(define-constant STATUS-END-OF-LIFE u5)
(define-constant STATUS-RECYCLED u6)

;; Map to store component information
(define-map components
  { component-id: (string-ascii 32) }
  {
    manufacturer-id: (string-ascii 32),
    product-type: (string-ascii 32),
    manufacture-date: uint,
    status: uint,
    current-owner: principal,
    last-updated: uint
  }
)

;; Map to store component history
(define-map component-history
  { component-id: (string-ascii 32), event-id: uint }
  {
    status: uint,
    timestamp: uint,
    handler: principal,
    notes: (string-ascii 128)
  }
)

;; Counter for history events
(define-data-var event-counter uint u0)

;; Check if caller is admin
(define-private (is-admin)
  (is-eq tx-sender (var-get admin))
)

;; Register a new component
(define-public (register-component
    (component-id (string-ascii 32))
    (manufacturer-id (string-ascii 32))
    (product-type (string-ascii 32)))
  (begin
    (asserts! (is-admin) (err u1))
    (asserts! (is-none (map-get? components { component-id: component-id })) (err u2))

    ;; Set component data
    (map-set components
      { component-id: component-id }
      {
        manufacturer-id: manufacturer-id,
        product-type: product-type,
        manufacture-date: block-height,
        status: STATUS-MANUFACTURED,
        current-owner: tx-sender,
        last-updated: block-height
      }
    )

    ;; Add first history entry
    (add-history-entry component-id STATUS-MANUFACTURED "Component manufactured")

    (ok true)
  )
)

;; Update component status
(define-public (update-component-status
    (component-id (string-ascii 32))
    (new-status uint)
    (notes (string-ascii 128)))
  (begin
    (asserts! (is-admin) (err u1))

    (match (map-get? components { component-id: component-id })
      component
        (begin
          ;; Update component status
          (map-set components
            { component-id: component-id }
            (merge component {
              status: new-status,
              last-updated: block-height
            })
          )

          ;; Add history entry
          (add-history-entry component-id new-status notes)

          (ok true)
        )
      (err u3)
    )
  )
)

;; Transfer component ownership
(define-public (transfer-ownership
    (component-id (string-ascii 32))
    (new-owner principal))
  (begin
    (match (map-get? components { component-id: component-id })
      component
        (begin
          (asserts! (is-eq (get current-owner component) tx-sender) (err u4))

          ;; Update component owner
          (map-set components
            { component-id: component-id }
            (merge component {
              current-owner: new-owner,
              last-updated: block-height
            })
          )

          ;; Add history entry
          (add-history-entry component-id (get status component) "Ownership transferred")

          (ok true)
        )
      (err u3)
    )
  )
)

;; Private function to add history entry
(define-private (add-history-entry
    (component-id (string-ascii 32))
    (status uint)
    (notes (string-ascii 128)))
  (begin
    (var-set event-counter (+ (var-get event-counter) u1))
    (map-set component-history
      { component-id: component-id, event-id: (var-get event-counter) }
      {
        status: status,
        timestamp: block-height,
        handler: tx-sender,
        notes: notes
      }
    )
    (var-get event-counter)
  )
)

;; Get component details
(define-read-only (get-component-details (component-id (string-ascii 32)))
  (map-get? components { component-id: component-id })
)

;; Get component history entry
(define-read-only (get-history-entry (component-id (string-ascii 32)) (event-id uint))
  (map-get? component-history { component-id: component-id, event-id: event-id })
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-admin) (err u1))
    (ok (var-set admin new-admin))
  )
)

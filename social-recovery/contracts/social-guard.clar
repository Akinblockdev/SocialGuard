;; Social Recovery Wallet
;; Allows recovery of wallet access through trusted guardians

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-GUARDIAN (err u101))
(define-constant ERR-NOT-ENOUGH-GUARDIANS (err u102))
(define-constant ERR-RECOVERY-ACTIVE (err u103))
(define-constant ERR-INVALID-PRINCIPAL (err u104))
(define-constant MIN-GUARDIAN-THRESHOLD u2)

;; Data vars
(define-data-var owner principal tx-sender)
(define-data-var recovery-state bool false)
(define-data-var recovery-deadline uint u0)
(define-data-var proposed-owner (optional principal) none)

;; Maps
(define-map guardians principal bool)
(define-map recovery-votes {guardian: principal, proposed: principal} bool)
(define-map guardian-count uint uint)

;; Read-only functions
(define-read-only (get-owner)
    (var-get owner))

(define-read-only (is-guardian (account principal))
    (default-to false (map-get? guardians account)))

(define-read-only (get-recovery-state)
    (var-get recovery-state))

;; Helper functions
(define-private (validate-principal (address principal))
    (match (principal-destruct? address)
        success true
        error false))

;; Public functions
(define-public (add-guardian (new-guardian principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-AUTHORIZED)
        (asserts! (not (is-guardian new-guardian)) ERR-ALREADY-GUARDIAN)
        (asserts! (validate-principal new-guardian) ERR-INVALID-PRINCIPAL)
        (map-set guardians new-guardian true)
        (map-set guardian-count u0 
            (+ (default-to u0 (map-get? guardian-count u0)) u1))
        (ok true)))

(define-public (remove-guardian (guardian principal))
    (begin
        (asserts! (is-eq tx-sender (var-get owner)) ERR-NOT-AUTHORIZED)
        (asserts! (is-guardian guardian) ERR-NOT-AUTHORIZED)
        (map-delete guardians guardian)
        (map-set guardian-count u0 
            (- (default-to u1 (map-get? guardian-count u0)) u1))
        (ok true)))

(define-public (initiate-recovery (new-owner principal))
    (begin
        (asserts! (is-guardian tx-sender) ERR-NOT-AUTHORIZED)
        (asserts! (not (var-get recovery-state)) ERR-RECOVERY-ACTIVE)
        (asserts! (>= (default-to u0 (map-get? guardian-count u0)) 
                     MIN-GUARDIAN-THRESHOLD)
                 ERR-NOT-ENOUGH-GUARDIANS)
        (asserts! (validate-principal new-owner) ERR-INVALID-PRINCIPAL)
        (var-set recovery-state true)
        (var-set recovery-deadline (+ block-height u144))
        (var-set proposed-owner (some new-owner))
        (map-set recovery-votes 
            {guardian: tx-sender, proposed: new-owner} true)
        (ok true)))

(define-public (support-recovery)
    (let ((proposed (unwrap! (var-get proposed-owner) ERR-NOT-AUTHORIZED)))
        (begin
            (asserts! (is-guardian tx-sender) ERR-NOT-AUTHORIZED)
            (asserts! (var-get recovery-state) ERR-NOT-AUTHORIZED)
            (map-set recovery-votes 
                {guardian: tx-sender, proposed: proposed} true)
            (ok true))))

(define-public (execute-recovery)
    (let ((proposed (unwrap! (var-get proposed-owner) ERR-NOT-AUTHORIZED))
          (votes (default-to u0 (map-get? guardian-count u0))))
        (begin
            (asserts! (var-get recovery-state) ERR-NOT-AUTHORIZED)
            (asserts! (>= votes MIN-GUARDIAN-THRESHOLD) ERR-NOT-ENOUGH-GUARDIANS)
            (asserts! (validate-principal proposed) ERR-INVALID-PRINCIPAL)
            (var-set owner proposed)
            (var-set recovery-state false)
            (var-set proposed-owner none)
            (ok true))))
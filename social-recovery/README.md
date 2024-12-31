# SocialGuard - Social Recovery Wallet Smart Contract

## Features

- Guardian management system
- Multi-guardian approval process
- 24-hour timelock for recovery actions
- Minimum threshold of 2 guardians required
- Principal validation for security
- Recovery state tracking

## Contract Functions

### Read-Only Functions

- `get-owner`: Returns the current wallet owner
- `is-guardian`: Checks if an address is a guardian
- `get-recovery-state`: Returns the current recovery state

### Public Functions

- `add-guardian`: Add a new guardian (owner only)
- `remove-guardian`: Remove an existing guardian (owner only)
- `initiate-recovery`: Start the recovery process (guardian only)
- `support-recovery`: Support an ongoing recovery (guardian only)
- `execute-recovery`: Complete the recovery process

## Error Codes

- `ERR-NOT-AUTHORIZED (u100)`: Unauthorized action
- `ERR-ALREADY-GUARDIAN (u101)`: Address is already a guardian
- `ERR-NOT-ENOUGH-GUARDIANS (u102)`: Below minimum guardian threshold
- `ERR-RECOVERY-ACTIVE (u103)`: Recovery already in progress
- `ERR-INVALID-PRINCIPAL (u104)`: Invalid principal address

## Setup

1. Install Clarinet
```bash
curl -sSL https://install.clarinet.sh | sh
```

2. Clone the repository
```bash
git clone https://github.com/yourusername/stx-social-recovery.git
cd stx-social-recovery
```

3. Test the contract
```bash
clarinet test
```

## Security Considerations

- Maintain a secure list of trusted guardians
- Ensure guardians are reliable and accessible
- Keep guardian threshold appropriate for your needs
- Test recovery process before relying on it
- Validate all principal addresses
# Blockchain-Based Electronics Component Lifecycle Management

This project implements a blockchain-based system for managing the lifecycle of electronic components using Clarity smart contracts. The system provides transparency, traceability, and security throughout the entire lifecycle of electronic components, from manufacturing to recycling.

## Overview

The system consists of five main contracts:

1. **Manufacturer Verification Contract**: Validates and verifies electronics manufacturers
2. **Component Tracking Contract**: Tracks electronic components throughout their lifecycle
3. **Performance Monitoring Contract**: Monitors and records component performance metrics
4. **End-of-Life Management Contract**: Manages component end-of-life processes
5. **Recycling Coordination Contract**: Coordinates electronics recycling

## Contracts

### Manufacturer Verification Contract

This contract maintains a registry of verified manufacturers and provides functions to:
- Register new manufacturers
- Verify manufacturers
- Check manufacturer verification status
- Retrieve manufacturer details

### Component Tracking Contract

This contract tracks components throughout their lifecycle and provides functions to:
- Register new components
- Update component status
- Transfer component ownership
- Record and retrieve component history

### Performance Monitoring Contract

This contract monitors component performance and provides functions to:
- Record performance metrics
- Set performance thresholds
- Check if performance is within acceptable thresholds
- Retrieve performance metrics and thresholds

### End-of-Life Management Contract

This contract manages the end-of-life process for components and provides functions to:
- Request end-of-life for components
- Approve end-of-life requests
- Update end-of-life status
- Set and retrieve component lifespan expectations
- Check if components have exceeded their expected lifespan

### Recycling Coordination Contract

This contract coordinates the recycling of components and provides functions to:
- Register and verify recycling facilities
- Schedule components for recycling
- Update recycling status
- Record recovered materials
- Retrieve facility and recycling request details

## Getting Started

### Prerequisites

- Clarity language environment
- Vitest for testing

### Installation

1. Clone the repository
2. Deploy the contracts to your blockchain environment

### Usage

Interact with the contracts using your blockchain client:

```clarity
;; Example: Register a manufacturer
(contract-call? .manufacturer-verification register-manufacturer "mfr123" "Acme Electronics" "San Francisco, CA")

;; Example: Register a component
(contract-call? .component-tracking register-component "comp456" "mfr123" "processor")

;; Example: Record performance metrics
(contract-call? .performance-monitoring record-metrics "comp456" u1000 70 u50 u2 u95)

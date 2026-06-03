# Streaming Monitor

**Namespace Prefix:** `smon`

## Description

Streaming Monitor is a free Salesforce Lightning app built by Philippe Ozil (Salesforce Labs) for monitoring and
debugging real-time streaming events within a Salesforce org. It provides a centralized UI to subscribe to, publish, and
inspect all supported Salesforce streaming event types.

## Problems It Solves

- Lack of visibility into streaming event activity across multiple event types in a single place
- Difficulty subscribing or unsubscribing from specific events through the standard UI
- No built-in tool for analyzing historical event data, patterns, or replaying events
- Missing centralized dashboard for org streaming limits and event usage metrics

## Key Features

- Subscribe to and monitor PushTopic, generic, platform, CDC, and monitoring events
- Publish events (generic and platform events) directly from the UI
- Auto-discover all available event channels in the org
- Timeline and table visualizations for received events
- Dynamic event filtering and flexible replay options
- Org limits and streaming event usage metrics dashboard
- Event source registration with onboarding guidance

## Links

- [GitHub Repository](https://github.com/pozil/streaming-monitor)
- [AppExchange Listing](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FYEEWUA5)

---
name: notion
description: Notion API for creating and managing pages, databases, and blocks.
homepage: https://developers.notion.com
metadata: { "clawdbot": { "emoji": "📝" } }
---

# Notion

Use the Notion API to create/read/update pages, data sources (databases), and blocks.

## Setup

1. Create an integration at https://notion.so/my-integrations
2. Copy the API key (starts with ntn_ or `secret_`)
3. Store it in the Envars tab of Setup UI
4. Share target pages/databases with your integration (click "..." -> "Connect to" -> your integration name)

## API Basics

All requests need:

```bash
curl -X GET "https://api.notion.com/v1/..." \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json"
```

> Note: The Notion-Version header is required. This skill uses 2025-09-03 (latest). In this version, databases are called "data sources" in the API.

## Common Operations

Search for pages and data sources:

```bash
curl -X POST "https://api.notion.com/v1/search" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json" \
 -d '{"query": "page title"}'
```

Get page:

```bash
curl "https://api.notion.com/v1/pages/{page_id}" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03"
```

Get page content (blocks):

```bash
curl "https://api.notion.com/v1/blocks/{page_id}/children" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03"
```

Create page in a data source:

```bash
curl -X POST "https://api.notion.com/v1/pages" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json" \
 -d '{
 "parent": {"database_id": "xxx"},
 "properties": {
 "Name": {"title": [{"text": {"content": "New Item"}}]},
 "Status": {"select": {"name": "Todo"}}
 }
 }'
```

Query a data source (database):

```bash
curl -X POST "https://api.notion.com/v1/data_sources/{data_source_id}/query" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json" \
 -d '{
 "filter": {"property": "Status", "select": {"equals": "Active"}},
 "sorts": [{"property": "Date", "direction": "descending"}]
 }'
```

Create a data source (database):

```bash
curl -X POST "https://api.notion.com/v1/data_sources" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json" \
 -d '{
 "parent": {"page_id": "xxx"},
 "title": [{"text": {"content": "My Database"}}],
 "properties": {
 "Name": {"title": {}},
 "Status": {"select": {"options": [{"name": "Todo"}, {"name": "Done"}]}},
 "Date": {"date": {}}
 }
 }'
```

Update page properties:

```bash
curl -X PATCH "https://api.notion.com/v1/pages/{page_id}" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json" \
 -d '{"properties": {"Status": {"select": {"name": "Done"}}}}'
```

Add blocks to page:

```bash
curl -X PATCH "https://api.notion.com/v1/blocks/{page_id}/children" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json" \
 -d '{
 "children": [
 {"object": "block", "type": "paragraph", "paragraph": {"rich_text": [{"text": {"content": "Hello"}}]}}
 ]
 }'
```

## Archive (No Delete)

There is no DELETE endpoint. Archive pages or blocks instead:

```bash
curl -X PATCH "https://api.notion.com/v1/pages/{page_id}" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json" \
 -d '{"archived": true}'
```

Same pattern for blocks: PATCH /v1/blocks/{block_id} with {"archived": true}.

## Pagination

All list endpoints return max 100 items. Handle pagination:

```bash
# First request
curl -X POST "https://api.notion.com/v1/search" ... -d '{"page_size": 100}'

# If has_more is true, pass start_cursor from previous response
curl -X POST "https://api.notion.com/v1/search" ... -d '{"page_size": 100, "start_cursor": "xxx"}'
```

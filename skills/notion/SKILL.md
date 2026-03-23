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

Data source query pagination:

```bash
curl -X POST "https://api.notion.com/v1/data_sources/{id}/query" \
 -H "Authorization: Bearer $NOTION_KEY" \
 -H "Notion-Version: 2025-09-03" \
 -H "Content-Type: application/json" \
 -d '{"start_cursor": "uuid-from-previous-response", "page_size": 100}'
```

Response includes "has_more": true and "next_cursor": "...". Loop until has_more is false. Applies to block children, search, and data source queries.

## Compound Filters

Combine filters with `and`/`or`:

```json
{
 "filter": {
 "and": [
 { "property": "Status", "status": { "equals": "In Progress" } },
 {
 "or": [
 { "property": "Priority", "select": { "equals": "High" } },
 { "property": "Due", "date": { "before": "2025-02-01" } }
 ]
 }
 ]
 }
}
```

## Property Types

Common property formats for database items:

- Title: `{"title": [{"text": {"content": "..."}}]}`
- Rich text: `{"rich_text": [{"text": {"content": "..."}}]}`
- Select: `{"select": {"name": "Option"}}`
- Multi-select: `{"multi_select": [{"name": "A"}, {"name": "B"}]}`
- Status (different from select): `{"status": {"name": "In Progress"}}`
- Date: `{"date": {"start": "2024-01-15", "end": "2024-01-16"}}`
- Checkbox: `{"checkbox": true}`
- Number: `{"number": 42}`
- URL: `{"url": "https://..."}`
- Email: `{"email": "a@b.com"}`
- People: `{"people": [{"id": "user_id"}]}`
- Relation: `{"relation": [{"id": "page_id"}]}`

## database_id vs data_source_id

When you search or retrieve a database, the response includes both IDs:

```json
{
 "object": "data_source",
 "id": "ds-abc123",
 "database_id": "db-abc123"
}
```

- Creating pages: use database_id → `"parent": {"database_id": "db-abc123"}`
- Querying: use data_source_id → `POST /v1/data_sources/ds-abc123/query`

Using the wrong ID will return a 404.

## Editing Pages

NEVER delete all blocks and rewrite a page. Find the specific block
that needs changing and update it via PATCH /v1/blocks/{block_id}.

Deleting blocks destroys child_database views, inline formatting,
and any structure the user added manually.

Steps:

1. GET /v1/blocks/{page_id}/children to find the target block
2. PATCH /v1/blocks/{block_id} with the updated content
3. Only append new blocks if adding net-new content

## Key Differences in 2025-09-03

- Databases -> Data Sources: Use /data_sources/ endpoints for queries and retrieval
- Two IDs: Each database now has both a database_id and a data_source_id (see above)
- Search results: Databases return as "object": "data_source" with their data_source_id
- Parent in responses: Pages show parent.data_source_id alongside parent.database_id
- Finding the data_source_id: Search for the database, or call GET /v1/data_sources/{data_source_id}

## Notes

- Page/database IDs are UUIDs (with or without dashes)
- The API cannot set database view filters - that's UI-only
- Rate limit: ~3 requests/second average
- Use is_inline: true when creating data sources to embed them in pages

## Caching

Cache IDs (database, page, etc) in cache/notion-ids.json to avoid repeated lookups.

Rules:

- Always read the cache file first, merge new entries, then write back
- Never overwrite the entire file
- If the cache file doesn't exist yet, create it

Schema:

```json
{
 "databases": {
 "Human-Readable Name": {
 "database_id": "uuid",
 "data_source_id": "uuid"
 }
 },
 "pages": {
 "Human-Readable Name": {
 "page_id": "uuid"
 }
 }
}
```

**When to cache:**

- After creating a new database or page you'll reference again
- After looking up a data_source_id for the first time
- When a skill or user gives you a named resource

Before any Notion operation: Check the cache first. If the ID is there, use it. Don't re-search.

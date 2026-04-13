/**
 * Direct MCP client for Stitch API - v2
 */

const API_KEY = 'AQ.Ab8RN6LazCKwxBmzBWdnwseIUznuCUfomAPBLpy0aCbfv031eg';
const MCP_ENDPOINT = 'https://stitch.googleapis.com/mcp';

let sessionId = null;

async function mcpRequest(method, params = {}) {
  const headers = {
    'Content-Type': 'application/json',
    'x-api-key': API_KEY,
  };

  if (sessionId) {
    headers['mcp-session-id'] = sessionId;
  }

  const body = JSON.stringify({
    jsonrpc: '2.0',
    method,
    params,
    id: Date.now()
  });

  const resp = await fetch(MCP_ENDPOINT, {
    method: 'POST',
    headers,
    body
  });

  // Try to get session ID from response headers
  const newSessionId = resp.headers.get('mcp-session-id');
  if (newSessionId) {
    sessionId = newSessionId;
    console.log('Got session:', sessionId);
  }

  const data = await resp.json();

  // If it's a tool response with auth error, try with different approach
  if (data.result?.content?.[0]?.text?.includes('authentication')) {
    console.log('Auth error, trying with bearer token...');

    const resp2 = await fetch(MCP_ENDPOINT, {
      method: 'POST',
      headers: {
        ...headers,
        'Authorization': `Bearer ${API_KEY}`
      },
      body
    });

    return resp2.json();
  }

  return data;
}

async function main() {
  console.log('=== Stitch Direct MCP Client v2 ===\n');

  try {
    // Create project
    console.log('1. Creating project...');
    const create = await mcpRequest('tools/call', {
      name: 'create_project',
      arguments: { title: 'CodeBuddy-v4' }
    });
    console.log('Create result:', JSON.stringify(create, null, 2).slice(0, 800));

    if (!create.result?.content?.[0]?.project?.id) {
      console.log('\nCould not create project via direct MCP. Checking existing projects...');

      const projResp = await mcpRequest('tools/call', {
        name: 'list_projects',
        arguments: {}
      });
      console.log('Projects:', JSON.stringify(projResp, null, 2).slice(0, 500));
    }

  } catch (error) {
    console.error('Error:', error.message);
  }
}

main();

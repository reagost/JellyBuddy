/**
 * Direct Stitch API call using fetch with SSE
 */

const API_KEY = 'AQ.Ab8RN6LazCKwxBmzBWdnwseIUznuCUfomAPBLpy0aCbfv031eg';

async function callMCP(method, params = {}) {
  const response = await fetch('https://stitch.googleapis.com/mcp', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': API_KEY,
    },
    body: JSON.stringify({
      jsonrpc: '2.0',
      id: Date.now(),
      method,
      params
    })
  });

  const text = await response.text();

  // Try to parse as JSON (may have multiple JSON objects concatenated)
  const results = [];
  const parts = text.split('\n').filter(l => l.trim());

  for (const part of parts) {
    try {
      results.push(JSON.parse(part));
    } catch {
      // Skip non-JSON lines
    }
  }

  return results;
}

async function main() {
  console.log('=== Testing Stitch API ===\n');

  try {
    // List tools
    console.log('1. Testing tools/list...');
    const tools = await callMCP('tools/list');
    console.log('Tools response:', JSON.stringify(tools[0]?.result?.tools?.slice(0, 3), null, 2));

    // Try to create project
    console.log('\n2. Creating project via tools/call...');
    const createResp = await callMCP('tools/call', {
      name: 'create_project',
      arguments: { title: 'CodeBuddy App' }
    });
    console.log('Create response:', JSON.stringify(createResp[0], null, 2));

    // If project created, try to generate screen
    if (createResp[0]?.result?.content?.[0]?.project?.id) {
      const projectId = createResp[0].result.content[0].project.id;
      console.log('\n3. Project created:', projectId);
      console.log('   Now try to generate screen...');

      // This is where it would fail due to streaming
      const genResp = await callMCP('tools/call', {
        name: 'generate_screen_from_text',
        arguments: {
          project_id: projectId,
          prompt: 'A mobile learning app home screen with purple theme',
          device: 'MOBILE'
        }
      });
      console.log('Generate response:', JSON.stringify(genResp[0], null, 2));
    }

  } catch (error) {
    console.error('Error:', error.message);
  }
}

main();

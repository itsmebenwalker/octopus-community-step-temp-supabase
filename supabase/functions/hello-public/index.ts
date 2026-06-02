Deno.serve(async (_req: Request) => {
  return new Response(
    JSON.stringify({ message: "Hello from hello-public! No auth required.", timestamp: new Date().toISOString() }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
})

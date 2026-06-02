Deno.serve(async (_req: Request) => {
  return new Response(
    JSON.stringify({ message: "Hello from hello-world!", timestamp: new Date().toISOString() }),
    { status: 200, headers: { "Content-Type": "application/json" } }
  )
})

local M = {}

local function ancestors(path)
  local seen = {}
  local components = vim.fn.split(path, "/")
  for i = 1, #components do
    local slice = { unpack(components, i) }
    table.insert(seen, vim.fn.join(slice, "/"))
  end

  return seen
end

--- Truncate paths intelligently. Given { "~/test/mod.rs", "~/test/more/mod.rs" },
--- this function will truncate the paths (in-place) to
--- { "test/mod.rs", "more/mod.rs" }.
--- @param paths string[]
--- @param opts { always_context: string[] }?
function M.truncate_paths(paths, opts)
  opts = opts or {
    always_context = {},
  }

  local seen = {}
  for _, path in ipairs(paths) do
    for _, anc in ipairs(ancestors(path)) do
      seen[anc] = (seen[anc] or 0) + 1
    end
  end

  for _, p in ipairs(opts.always_context) do
    seen[p] = (seen[p] or 0) + 1
  end

  for i, path in ipairs(paths) do
    local found = false
    local ancstrs = ancestors(path)
    for j = #ancstrs, 1, -1 do
      local anc = ancstrs[j - 1] or ancstrs[j]
      paths[i] = anc
      if seen[anc] == 1 then
        found = true
        break
      end
    end
    if not found then
      paths[i] = ancstrs[-1]
    end
  end
end

return M

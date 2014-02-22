
sequence = {
  "wait"
  "tween"
}

{
  whitelist_globals: {
    ["."]: {
      "love", "newproxy"
      unpack sequence
    }
  }
}


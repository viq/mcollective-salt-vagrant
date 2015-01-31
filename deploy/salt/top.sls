base:
  'middleware':
    - grains.roles.middleware
  'node*':
    - grains.roles.node
  'node\d*[02468]':
    - match: pcre
    - grains.cluster.alpha
  'node\d*[13579]':
    - match: pcre
    - grains.cluster.bravo

# Hourglass_sorting

The Hourglass sorter is a Parallel In Serial Out (PISO) sorter for FPGA fabric. The name comes from the emergent behavior of the data, which moves through a funnel tree like sand in a Hourglass.

It is similar to a tournament sorter, but instead of having only one output per tournament, it can hold two (first and second place). This makes the latency between outputs zero, while avoiding the huge fanout that comes from propagating the "free" space from the output backwards.

TODO: Add a better description and graphics

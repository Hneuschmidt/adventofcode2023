module tools
function file_to_string(fn)
    open(io->read(io, String), fn)
end

intparse(x) = parse(Int, x)
emptyfilter(xs) = filter(!isempty, xs)
whitespacefilter(xs) = filter(!isspace, xs)
intparse_all(str) = parse.(Int, [m.match for m in eachmatch(r"-?\d+", str)])

end # module tools

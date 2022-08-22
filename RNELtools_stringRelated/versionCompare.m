function b = versionCompare(lhs,op,rhs)
% VERSIONCOMPARE Compare two version numbers, e.g. '1.5.12' '<' '1.6.0.1'
% 
% The version number strings must be all-numeric (letters not supported)

% Process inputs; turn strings into arrays of digits, parse the operator
lhs = getParts(lhs);
rhs = getParts(rhs);
opTable = containers.Map({'<' '<=' '==' '>=' '>'},...
                         {@lt @le  @eq  @ge  @gt});
if ischar(op)
    op = opTable(op);
else
    assert(isa(op,'function_handle'),'Operator must be either a string or function handle');
end

% Pad ends of the arrays with zeros to ensure the same lengths
n = max(length(lhs),length(rhs));
lhs(end:n) = 0;
rhs(end:n) = 0;

% Compute the sign of the difference (-1, 0, or 1 for each component), and
% multiply each by decreasing factors of ten and sum. Compare the result to 0
% with the operator requested.
b = op(sign(lhs-rhs) * 10.^(-1*(1:n))',0);

    function parts = getParts(str)
        [major,~,~,idx] = sscanf(str,'%d');
        minors = sscanf(str(idx:end),'.%d');
        parts = [major minors'];
    end
end

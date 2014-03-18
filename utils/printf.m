function printf(debug_, str, varargin)
    global debug
    if (debug >= debug_)
        fprintf(str, varargin{:});
    end
end
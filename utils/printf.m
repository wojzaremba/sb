function printf(varargin)
  global debug;
  if (debug >= 1)
    fprintf(varargin{:});
    return;
  end
end
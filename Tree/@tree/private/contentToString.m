function str = contentToString(content)
	% Subfunction to turn any content into a decent string
	if isempty(content)
		% Nothing -> print the void symbol
		str = 'null';
	elseif ~ischar(content)

		if numel(content) == 1
			% Scalar stuff we most probably be able to print
			if islogical(content)

				if content
					str = 'true';
				else
					str = 'false';
				end

			elseif isstruct(content)
				% Struct
				fnames = fieldnames(content);

				if numel(fnames) == 1
					% Struct with 1 field -> print it
					str = [fnames{1} '->' content.(fnames{1})];
				else
					% Print nbr of fields
					str = ['struct.' num2str(numel(fnames)) '_fields'];
				end

			elseif iscell(content)

				% Cell with one element -> append cell and print element
				str = ['cell:' contentToString(content{1})];

			elseif isa(content, 'node')
				% tmp = [ "a","b"];
					% string(content.name),
					% string(['time: ' contentToString(content.time)]),
					% string(['data: ' contentToString(content.data)])]
				str = ['node ' contentToString(content.name)];
			elseif isobject(content)
				% Object with 'name' property -> print it
				if (isprop(content, 'name'))
					str = ['obj.name:' contentToString(content.name)];
				end

			elseif isa(content, 'function_handle')
				% Function handle, lets's call it without parameters
				str = content();

			else
				% Scalar number -> print it
				str = num2str(content);
			end

		else
			% Matrix -> print its size
			dims = size(content);
			str = '<';

			for d = dims
				str = [str num2str(d) 'x']; %#ok<AGROW>
			end

			str(end) = ' ';
			str = [str class(content(1)) '>'];
		end

	else
		% A string -> print it
		str = content;
	end

end

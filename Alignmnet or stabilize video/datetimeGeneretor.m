function t2 = datetimeGeneretor() 

t = datetime('now');
t1 = char(t);

cnt = 0;
for i = 1:size(t1,2)
    tmp = str2num(t1(i));
    if ~isempty(tmp)
        cnt = cnt+1;
        t2(cnt) = num2str(tmp);
    end
end

end
def wait(time, increment = 5, elapsed_time = 0, &block)
    begin
        yield
        rescue Exception => e
        if elapsed_time >= time
            raise e
            else
            sleep increment
            wait(time, increment, elapsed_time + increment, &block)
        end
    end
end


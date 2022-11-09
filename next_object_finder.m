function [next_object,end_status] = next_object_finder(cur_object,path,props,props_dots,im,arrow_ind,treasure_id)
%The function takes in the current object, the path, the properties of the objects and yellow dots,
%the image file, arrow object indices and the treasure object indices as the
%input arguments and returns the next object and a variable to indicate if there is a next object

end_status = 0;     			%Variable to identify the presence of next object
next_object = [];   			%Next object variable initialised as an empty vector
point1 = props(cur_object).Centroid;    	%Centroid of arrow is found
id = find(arrow_ind(1,:)==cur_object);  	%indices of yellow dot of the arrow is found
point2 = props_dots(arrow_ind(2, id)).Centroid; 		%Centroid of yellow dot is found
line = point2 - point1; 			%A directional vector is formed from point 1 to point 2

%The magnitude by which to extend the directional vector is calculated. A smaller magnitude will
%result in more iterations while a larger value might cause some objects to not to be detected
extend_length = [line(1)/max(abs(line)) line(2)/max(abs(line))];
%An equation is created to check if the line in with the bounding box of an object
inobj = @(y,b) (y(1)>b(1)).*(y(1)<b(1)+b(3)).*(y(2)>b(2)).*(y(2)<b(2)+b(4));
flag=1; 		%Flag used to indicate when the next object is found

%The directional vector is extended
new_line = point1 + line + extend_length;
%List of objects that needs to be considered for the treasure hunt is created by removing the
%treasure objects and the arrows that are in the path from the list of all objects
obj_list = [setdiff([1:numel(props)],[treasure_id path])];
%If the list is empty it implies there is no next object. This is indicated and function is exited
if(isempty(obj_list))
    end_status=1;
    return;
end

%If the next object is not detected and the directional vector is within the bounds of the image,
%the search for the next object continues
while(flag&&abs(new_line(1))<=length(im)&&abs(new_line(2))<=height(im))
    for i=obj_list
        %If the directional vector is within an object bounding box, the object index is returned as the
        %next object and the loop is quit
        if(inobj(new_line,props(i).BoundingBox))
            next_object = i;
            flag=0;
            break;
        end
    end
    %If the next object is not found, extend the direction vector and search again
    new_line = new_line + extend_length;
end

%If no next object is found, pass this information to the main code
if(isempty(next_object))
    end_status = 1;
end

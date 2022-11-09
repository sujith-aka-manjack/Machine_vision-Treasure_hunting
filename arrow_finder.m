function [arrow_id] = arrow_finder(props,props_dots)
%The function takes in the properties of the objects and yellow dots as input arguments and returns %both the index of the arrow object and the index of the yellow dot belonging to that arrow
arrow_id = [];
%An equation is created which return 1 if the point y belongs to the bounding box b or else a 0
inobj = @(y,b) (y(1)>b(1)).*(y(1)<b(1)+b(3)).*(y(2)>b(2)).*(y(2)<b(2)+b(4));
for i=1:numel(props)
    for j=1:numel(props_dots)
        %If the centroid of the yellow dot is inside the bounding box of an arrow, the object is marked
        %as an arrow and the yellow dot is linked to the arrow
        if(inobj(props_dots(j).Centroid,props(i).BoundingBox))
            arrow_id(1,end+1) = i;
            arrow_id(2,end) = j;
            %Break the loop once the object is identified as an arrow
            break;
        end
    end
end
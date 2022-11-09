%% Reading image
im = imread('Treasure_hard5.jpg');     %Load the required image file
imshow(im);
pause;
 
%% Binarisation
bin_threshold = 0.1;                %Threshold value set for binarisation
bin_im = im2bw(im, bin_threshold);  %Image converted to binary using the threshold
%Visualise the binarisation result and pause till user acknowledgment
imshow(bin_im);
pause;
 
%% Extracting connected components
con_com = bwlabel(bin_im);
imshow(label2rgb(con_com));
pause;
 
%% Computing object's properties
props = regionprops(con_com);
 
%% Drawing bounding boxes
n_objects = numel(props);
imshow(im);
hold on;
for object_id = 1 : n_objects
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'r');
end
hold off;
pause;
 
%% Extracting connected components for the yellow dots
%Selecting pixels with yellow colour
im_point = im(:,:,1)>150 & im(:,:,2)>200 & im(:,:,3)<100;  
im_point = uint8(im_point); 			   %Converting logical datatype to image type
im_concom_point = bwlabel(im_point);       %Connected components extracted
props_dots = regionprops(im_concom_point); %Object properties computed
 
%% Drawing bounding boxes for yellow dots
n_objects = numel(props_dots);
imshow(im);
hold on;
for object_id = 1 : n_objects
    rectangle('Position', props_dots(object_id).BoundingBox, 'EdgeColor', 'r');
end
hold off;
pause

%% Arrow/non-arrow determination
%Function to find objects which are arrows. It returns both the index of the arrow object and the %index of the yellow dot belonging to that arrow
arrow_ind = arrow_finder(props,props_dots);    
 
%% Finding the red arrow (starting arrow)
start_arrow_id = 0;
%Check the colour of the centroid of each arrow until the red one is found
for arrow_num = 1 : length(arrow_ind)
    object_id = arrow_ind(1,arrow_num);    %Determining the arrow id
    
    %Extracting the colour of the centroid point of the current arrow
    centroid_colour = im(round(props(object_id).Centroid(2)), round(props(object_id).Centroid(1)), :); 
    if centroid_colour(:, :, 1) > 240 && centroid_colour(:, :, 2) < 10 && centroid_colour(:, :, 3) < 10
    %If the centroid point is red, then its id is memorised and the loop is breaked
        start_arrow_id = object_id;
        break;
    end
end
 
%% Tresure hunting
 cur_object = start_arrow_id; %Start from the red arrow and set it as the current object
 path = [];
 treasure_id = [];
 end_status = 0;
 while(end_status==0)
    %If the current object is an arrow, add it to the path and compute the next object
    while ismember(cur_object, arrow_ind(1,:))  
        path(end + 1) = cur_object;
        %Function to find the next object pointed by the current object
        cur_object = next_object_finder(cur_object,path,props,props_dots,im,arrow_ind,treasure_id);  
    end
    %If the current object is not an arrow then add it to the treasure
    treasure_id(end + 1) = cur_object;
    %Computing next object pointed by the last arrow in the path while ignoring the identified %treasure objects
    [cur_object end_status] = next_object_finder(path(end),path,props,props_dots,im,arrow_ind,treasure_id);
 end
 
%% visualisation of the path
imshow(im);
hold on;
for path_element = 1 : numel(path)
    object_id = path(path_element); 	%Determining the object id
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'y');
    str = num2str(path_element);
    text(props(object_id).BoundingBox(1), props(object_id).BoundingBox(2), str, 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 14);
end
 
%Visualisation of the treasure
count = 1;		%Variable used to label the treasure number
for i=[treasure_id]
    rectangle('Position', props(i).BoundingBox, 'EdgeColor', 'g');
    str = ['Treasure - ', num2str(count)];
    text(props(i).BoundingBox(1)-0, props(i).BoundingBox(2)-10, str, 'Color', 'g', 'FontWeight', 'bold', 'FontSize', 11);
    count= count+1;
end
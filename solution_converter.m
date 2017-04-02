%% Process Model Evaulations
clear;
clc; 
DIR_NAME = 'solutions\SP500\';
text_ext = strcat(DIR_NAME, '*.txt');
files = dir(text_ext);      

%% Convert

num_text =length(files);

for i = 1:num_text
    
    % Read image from database
    file_ext = strcat(DIR_NAME, files(i).name);    
    temp_mat = load(file_ext);
    
    % change to matrix
    file_ext = file_ext(1:end-4);
    file_ext = [file_ext, '.mat'];
    disp(file_ext);
    save(file_ext, 'temp_mat');
end
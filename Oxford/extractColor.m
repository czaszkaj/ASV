clear all
close all
clc
%% Library and paths
run ../vlfeat-0.9.18/toolbox/vl_setup
dataset_dir = './Oxford_dataset/';
Lname = {'bark','bikes','boat','graf','leuven','trees','ubc','wall'};
detectType = 1;
diary('d_color.txt')

%% Extract the descriptor from the whole dataset
T = 0;
F = 0;
for i = 1:8
    for j = 1:6
        tic
        fprintf('i:%d  j:%d\n',i,j)
        im1_org = imread([dataset_dir,Lname{i},'/img',num2str(j),'.ppm']);

        if size(im1_org,3)>1
            im1 = rgb2gray(im1_org);
        end
        if detectType == 1
            %% Initialize the detected frame for fair comparison
            [f,d_sift] = extract(im1,'sift'); % always use sift as standard
            %% Remove same position points
            id_used = [1];
            for f_i = 1:size(f,2)
                temp = f(:,f_i)';
                line = [temp(1:2)];
                if f_i>1 && norm(tempLine(1:2)-line(1:2)) ~= 0
                    id_used = [id_used,f_i];
                end
                tempLine = line;
            end

            f = f(:,id_used);
            d_sift = d_sift(:,id_used);
            

        end
        
        %% Color matching
        %fprintf('extract for color combinations\n')
        %d_color = vl_asvcovdet(im1_org, opt, f, des, isInter);
        d_color = [];
        f_color = [];
        if size(im1_org,3) > 1
            for r = 0:1            
                for g = 0:1
                    for b = 0:1
                        im1_tmp = im1_org;
                        %fprintf('r:%d  g:%d  b:%d\n',r,g,b)
                        im1_tmp(:,:,1) = im1_tmp(:,:,1)*r;
                        im1_tmp(:,:,2) = im1_tmp(:,:,2)*g;
                        im1_tmp(:,:,3) = im1_tmp(:,:,3)*b;

                        [f,d_sift] = extract(im1_tmp,'sift');
                        d_color = [d_color, d_sift];
                        f_color = [f_color, f];                    
                    end
                end
            end
            
            %% Remove same position points
            %fprintf('Remove duplicates\n')
            [f_color, ind] = sort(f_color);
            d_color = d_color(ind);

            id_used = [1];
            for f_i = 1:size(f_color,2)
                temp = f_color(:,f_i)';
                line = [temp(1:2)];
                if f_i>1 && norm(tempLine(1:2)-line(1:2)) ~= 0
                    id_used = [id_used,f_i];
                end
                tempLine = line;
            end

            f_color = f_color(:,id_used);
            d_color = d_color(:,id_used);
        else
            d_color = d_sift;
            f_color = f;
        end
        
        
        %% Save
        if detectType == 1
            nameF = ['./imageFD/DoG/',num2str(i),'/',num2str(j)];
        end
        if size(dir(nameF),1) == 0
            mkdir(nameF);
        end


        save([nameF,'/COLOR'],'f','d_color');
        t = toc;
        fprintf('time cost: %.2f secs\n',t);
        T = T+t;
        F = F+ size(d_color,2);
    end
end



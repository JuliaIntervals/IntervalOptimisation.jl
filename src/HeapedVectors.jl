__precompile__()

module HeapedVectors

import Base: getindex, length, push!, isempty,
        pop!, resize!, popfirst!
using IntervalArithmetic
export heap

"""
All the elements are arranged in such a manner that the value in every node of index i is smaller than both of the values which are present in its child node (2*i,2*i+1) this data structure is called minimum heap data structure. 
"""   

struct heap{T,F<:Function}
           data::Vector{T}
           by::F

           function heap(v::Vector{T},by::F) where {T,F}

                 new{T,F}(heaping(v,by),by)
           end
        end

 heap(data::Vector{T}) where {T} = heap(v, identity)

       

function heaping(v,by) 
	 ar=[]
         for i=1:length(v) 
          insert!(ar,i,v[i])
          floatup(length(ar),ar,by)
         end
         return ar
     end

function floatup(index,ar,by)	
  par = convert(Int,floor(index/2))
  if index<=1
        return ar 
    end
  if by(ar[index])<by(ar[par])
        temp=ar[par]
        ar[par]=ar[index]
        ar[index]=temp
    end
  floatup(par,ar,by)
end


function push!(v::heap{T}, x::T) where {T}
	insert!(v.data,length(v.data)+1,x)
	floatup(length(v.data),v.data,v.by)
    return v
end

isempty(v::heap) = isempty(v.data)

function popfirst!(v::heap{T}) where {T}
	if length(v.data)==0
		return 
	end	
    if length(v.data)>2
    	temp=v.data[length(v.data)]
    	v.data[length(v.data)]=v.data[1]
    	v.data[1]=temp
    	Min=pop!(v.data)
    	bubbledown(1,v::heap{T})
    
    elseif length(v.data)==2
    	temp=v.data[length(v.data)]
    	v.data[length(v.data)]=v.data[1]
    	v.data[1]=temp
    	Min=pop!(v.data)
    else
    	Min=pop!(v.data)	
    end
    return Min
end

function bubbledown(index,v::heap{T}) where{T}
	left=index*2
	right=index*2+1
	smallest=index
	if length(v.data)+1>left && v.by(v.data[smallest])>v.by(v.data[left])
		smallest=left
	end
	if length(v.data)+1>right && v.by(v.data[smallest])>v.by(v.data[right])
		smallest=right
	end
	if smallest != index
	   temp=v.data[index]
	   v.data[index]=v.data[smallest]
	   v.data[smallest]=temp
	   bubbledown(smallest,v)
	end
end

function cutoff(A::heap,index,x,ran)
	if index>length(A.data)
		return A
	end
	if A.by(A.data[index])>=A.by(x)
	    A.data[index]=(Interval(ran[1],ran[2]),ran[1])
	end    
	cutoff(A,index*2,x,ran)
	cutoff(A,index*2+1,x,ran)
end

function resize!(A::heap,x)
        if length(A.data)==0
           return A
        end
	ran=rand(Int,2)
	r=Interval(ran[1],ran[2])
	cutoff(A,1,x,ran)
	global a=2 
	global k=1
	while k<=length(A.data)
        if A.by(A.data[k])==convert(Float64,ran[1])
        	break
        end
        k=k+1
        a=a+1
    end
    while true
           if a>length(A.data)
	        break
	    end	
	    if A.by(A.data[a])!=convert(Float64,ran[1])
		    temp=A.data[a]
		    A.data[a]=A.data[k]
		    A.data[k]=temp
		    k=k+1
	    end	
	    a=a+1
    end

    while length(A.data)>0		
	    if A.by(A.data[length(A.data)])==convert(Float64,ran[1])
		    pop!(A.data)	 
    	    else
                    break   
             end 
    end
    if length(A.data)==0
       return A
    end
    ar=heaping(A.data,A.by) 
    for i=1:length(A.data)
        A.data[i]=ar[i] 
    end
    return A 
end    



end



		